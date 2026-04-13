{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  # LazyVim config files
  xdg.configFile."nvim" = {
    source = ../files/nvim;
    recursive = true;
  };

  # LSP servers and tools installed via Nix (not Mason)
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    ruby-lsp
    typescript-language-server
    terraform-ls
    pyright
    bash-language-server
    marksman
    vscode-json-languageserver
    yaml-language-server

    # Formatters & linters
    stylua
    prettierd
    rubocop
    ruff
    shfmt
    shellcheck

    # Tools needed by neovim plugins
    gcc
    gnumake
    nodejs
    unzip
  ];
}
