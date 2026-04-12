return {
  -- Disable Mason (we install LSP servers via Nix)
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
}
