{ ... }:

{
  # Karabiner needs a writable config (not a Nix store symlink)
  # Copy instead of symlink via activation script
  home.activation.karabinerConfig = {
    after = [ "writeBoundary" ];
    before = [];
    data = ''
      mkdir -p ~/.config/karabiner
      cp -f ${../files/karabiner/karabiner.json} ~/.config/karabiner/karabiner.json
      chmod 644 ~/.config/karabiner/karabiner.json
    '';
  };
}
