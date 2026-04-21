return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          base = "#121314",
          mantle = "#121314",
          crust = "#121314",
        },
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        mason = true,
        mini = true,
        native_lsp = { enabled = true },
        notify = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
