{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

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
