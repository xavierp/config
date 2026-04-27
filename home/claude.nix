{ lib, ... }:

let
  claudeDir = ../files/claude;
in
{
  # Copy settings.json on each rebuild (not symlinked — Claude Code needs write access)
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -m 644 ${claudeDir}/settings.json "$HOME/.claude/settings.json"
  '';

  home.file.".claude/mcp.json".source = "${claudeDir}/mcp.json";
  home.file."CLAUDE.md".source = "${claudeDir}/CLAUDE.md";
}
