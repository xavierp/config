{ pkgs, ... }:

{
  # elk-herd — device manager pour instruments Elektron (Digitakt…)
  # Web app Elm servie en localhost, WebMIDI => Chrome uniquement.
  home.packages = [ (pkgs.callPackage ../pkgs/elk-herd { }) ];
}
