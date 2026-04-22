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

  # Compact at 400k instead of 1M to improve prompt cache hit rate
  # See: https://github.com/anthropics/claude-code/issues/45756#issuecomment-4231739206
  # home.sessionVariables.CLAUDE_CODE_AUTO_COMPACT_WINDOW = "400000";
}
