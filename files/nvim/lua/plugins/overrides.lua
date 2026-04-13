return {
  -- Disable Mason (we install LSP servers via Nix)
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
}
