{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        node = "25";
        ruby = "4";
        python = "3.14";
        terraform = "1";
      };
    };
  };
}
