{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    # nixpkgs 2026-06 : un test du checkPhase assert des bits de permission
    # (`mode for bin/helper`) qui échoue dans le sandbox Nix. Faux positif,
    # on saute le checkPhase. À retirer quand le package upstream est corrigé.
    package = pkgs.mise.overrideAttrs (_: { doCheck = false; });

    globalConfig = {
      settings = {
        auto_install = true;
      };
      tools = {
        node = "25";
        ruby = "4";
        python = "3.14";
        terraform = "1";
      };
    };
  };
}
