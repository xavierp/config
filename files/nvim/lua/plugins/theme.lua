return {
  -- Use nord theme to match Ghostty
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
  },
  -- Tell LazyVim to use nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
