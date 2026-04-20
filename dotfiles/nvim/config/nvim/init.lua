vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.updatetime = 250

-- Bootstrap lazy.nvim on first launch so plugins install automatically.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.10.0",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash", "c", "go", "javascript", "json", "lua", "markdown",
        "python", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = function()
      local servers = { "lua_ls", "ts_ls", "pyright", "rust_analyzer" }
      if vim.fn.executable("go") == 1 then
        table.insert(servers, "gopls")
      end
      return { ensure_installed = servers }
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader><Tab>", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Prev hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      end,
    },
  },

  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- nvim-autopairs over mini.pairs: treesitter-aware, skips pairing inside
  -- strings/comments, and integrates with nvim-cmp if we add completion later.
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "gruvbox",
        section_separators = "",
        component_separators = "",
      },
    },
  },
})

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Directional window navigation. Overrides <C-l>'s default (redraw screen).
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window: left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window: down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window: up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window: right" })

-- Open neo-tree on startup without stealing focus. `show` is idempotent,
-- so it's safe if neo-tree's netrw hijack already opened the tree (e.g.
-- when nvim was launched against a directory). Force filetype detection
-- first so the guard can reliably skip diff mode and short-lived git
-- editor buffers (commit/rebase/merge) where the tree is just noise.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.o.diff then return end
    vim.cmd.filetype("detect")
    local ft = vim.bo.filetype
    if ft == "gitcommit" or ft == "gitrebase" or ft == "gitsendemail" then
      return
    end
    vim.cmd("Neotree show")
  end,
})

-- Local, per-machine overrides. Sourced last so it can override anything above.
local local_config = vim.fn.stdpath("config") .. "/init.local.lua"
if (vim.uv or vim.loop).fs_stat(local_config) then
  dofile(local_config)
end
