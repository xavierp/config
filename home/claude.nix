{ ... }:

let
  claudeDir = ../files/claude;
in
{
  home.file.".claude/settings.json".source = "${claudeDir}/settings.json";
  home.file.".claude/mcp.json".source = "${claudeDir}/mcp.json";
}
