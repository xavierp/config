return {
  -- Disable Mason (we install LSP servers via Nix)
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },

  -- Neo-tree on the right
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { position = "right" },
    },
  },

  -- Disable markdownlint diagnostics (too noisy, makes markdown unreadable)
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- replace, don't extend: clears markdownlint-cli2 from the markdown extra
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft.markdownreact = {}
    end,
  },
}
