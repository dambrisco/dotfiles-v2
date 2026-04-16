return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        m("n", "gd", vim.lsp.buf.definition, "Go to definition")
        m("n", "gr", vim.lsp.buf.references, "References")
        m("n", "gi", vim.lsp.buf.implementation, "Implementation")
        m("n", "K",  vim.lsp.buf.hover, "Hover")
        m("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        m("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        m("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
        m("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        m("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
      end

      local servers = {
        nil_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        ts_ls = {},
        pyright = {},
      }

      for name, cfg in pairs(servers) do
        lspconfig[name].setup(vim.tbl_extend("force", {
          capabilities = caps,
          on_attach = on_attach,
        }, cfg))
      end
    end,
  },
}
