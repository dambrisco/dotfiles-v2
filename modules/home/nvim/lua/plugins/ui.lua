return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    opts = { use_icons = true },
    config = function(_, opts)
      require("mini.statusline").setup(opts)
    end,
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
}
