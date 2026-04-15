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

  # Spell files managed by Nix
  xdg.configFile."nvim/spell/fr.utf-8.spl".source = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.spl";
    sha256 = "0q9vws3fyi33yladjx5n0f6w0gbk76mz2n6fb8bpr24dp419gyxb";
  };
  xdg.configFile."nvim/spell/fr.utf-8.sug".source = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/fr.utf-8.sug";
    sha256 = "0n1zddfa5mhk2lxm5azixx8fzdvk6z5277m8hsrbp41cnhrbr502";
  };

  # LSP servers and tools installed via Nix (not Mason)
  home.packages = with pkgs; [
    # LSP servers
    lua-language-server
    ruby-lsp
    vtsls                 # TypeScript LSP
    terraform-ls
    pyright
    bash-language-server
    marksman
    vscode-json-languageserver
    yaml-language-server
    dockerfile-language-server
    docker-compose-language-service

    # Formatters & linters
    stylua
    prettierd
    rubocop
    ruff
    shfmt
    shellcheck
    markdownlint-cli2

    # Tools needed by neovim plugins
    tree-sitter           # treesitter CLI for compiling parsers
    lazygit               # git TUI (Space g g in LazyVim)
    gcc
    gnumake
    nodejs
    unzip
  ];
}
