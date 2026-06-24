{ pkgs, ... }:

{
  # Runtimes globaux (remplacent mise). Versions pinnées par flake.lock.
  # Les projets pinnent leur propre version via devenv quand c'est en place.
  home.packages = with pkgs; [
    ruby_4_0
    nodejs_26
    python314
    terraform
  ];
}
