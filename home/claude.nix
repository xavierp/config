{ lib, pkgs, ... }:

let
  claudeDir = ../files/claude;

  # Re-clones the official marketplace and re-installs every enabled plugin
  # listed in ~/.claude/settings.json on each rebuild — so plugins stay
  # current without manual `/plugin update`.
  syncPlugins = pkgs.writeShellApplication {
    name = "claude-plugins-sync";
    runtimeInputs = with pkgs; [ git jq coreutils ];
    text = ''
      MARKETPLACE_URL="https://github.com/anthropics/claude-plugins-official.git"
      MARKETPLACE_NAME="claude-plugins-official"
      PLUGINS_ROOT="$HOME/.claude/plugins"
      MARKETPLACE_DIR="$PLUGINS_ROOT/marketplaces/$MARKETPLACE_NAME"
      CACHE_DIR="$PLUGINS_ROOT/cache/$MARKETPLACE_NAME"
      SETTINGS="$HOME/.claude/settings.json"
      STATE="$PLUGINS_ROOT/installed_plugins.json"

      if [ ! -f "$SETTINGS" ]; then
        echo "[claude-plugins] no settings.json yet, skipping"
        exit 0
      fi

      mkdir -p "$CACHE_DIR" "$PLUGINS_ROOT/marketplaces"

      TMP=$(mktemp -d)
      trap 'rm -rf "$TMP"' EXIT

      # 1. Fresh shallow clone of the marketplace, atomic swap
      if ! git clone --quiet --depth 1 "$MARKETPLACE_URL" "$TMP/marketplace"; then
        echo "[claude-plugins] marketplace clone failed, keeping existing"
        exit 0
      fi
      rm -rf "$MARKETPLACE_DIR"
      mv "$TMP/marketplace" "$MARKETPLACE_DIR"

      MARKETPLACE_JSON="$MARKETPLACE_DIR/.claude-plugin/marketplace.json"

      # initialize state file if missing
      if [ ! -f "$STATE" ]; then
        echo '{"version":2,"plugins":{}}' > "$STATE"
      fi

      now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      enabled=$(jq -r --arg mp "@$MARKETPLACE_NAME" '
        (.enabledPlugins // {})
        | to_entries
        | map(select(.value == true and (.key | endswith($mp))))
        | .[].key
      ' "$SETTINGS")

      for full_name in $enabled; do
        name="''${full_name%@"$MARKETPLACE_NAME"}"

        entry=$(jq -c --arg n "$name" '.plugins[] | select(.name == $n)' "$MARKETPLACE_JSON")
        if [ -z "$entry" ]; then
          echo "[claude-plugins] WARN: $name not in marketplace, skipping"
          continue
        fi

        src_kind=$(echo "$entry" | jq -r 'if (.source | type) == "string" then "local" else .source.source end')
        srcdir=""

        case "$src_kind" in
          local)
            rel=$(echo "$entry" | jq -r '.source' | sed 's|^\./||')
            srcdir="$MARKETPLACE_DIR/$rel"
            ;;
          url|git-subdir)
            url=$(echo "$entry" | jq -r '.source.url')
            ref=$(echo "$entry" | jq -r '.source.ref // empty')
            sub=$(echo "$entry" | jq -r '.source.path // empty')
            clone_tmp=$(mktemp -d -p "$TMP")
            if [ -z "$ref" ]; then
              git clone --quiet --depth 1 "$url" "$clone_tmp" || { echo "[claude-plugins] clone $url failed"; continue; }
            else
              git clone --quiet "$url" "$clone_tmp" || { echo "[claude-plugins] clone $url failed"; continue; }
              git -C "$clone_tmp" checkout --quiet "$ref" || true
            fi
            srcdir="$clone_tmp''${sub:+/"$sub"}"
            ;;
          *)
            echo "[claude-plugins] WARN: $name source '$src_kind' unsupported"
            continue
            ;;
        esac

        if [ ! -d "$srcdir" ]; then
          echo "[claude-plugins] WARN: $name source dir missing ($srcdir)"
          continue
        fi

        version=$(jq -r '.version // "unknown"' "$srcdir/.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")
        dest="$CACHE_DIR/$name/$version"
        mkdir -p "$(dirname "$dest")"
        rm -rf "$dest"
        cp -R "$srcdir" "$dest"
        chmod -R u+w "$dest"

        # rewrite the user-scope entry in installed_plugins.json, keep others
        tmp_state=$(mktemp)
        jq --arg k "$full_name" --arg path "$dest" --arg ver "$version" --arg now "$now" '
          .plugins[$k] = (
            ((.plugins[$k] // []) | map(select(.scope != "user")))
            + [{scope: "user", installPath: $path, version: $ver, installedAt: $now, lastUpdated: $now}]
          )
        ' "$STATE" > "$tmp_state" && mv "$tmp_state" "$STATE"

        echo "[claude-plugins] $name@$version"
      done
    '';
  };
in
{
  # Copy settings.json on each rebuild (not symlinked — Claude Code needs write access)
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -m 644 ${claudeDir}/settings.json "$HOME/.claude/settings.json"
  '';

  # Sync marketplace + enabled plugins to latest upstream on each rebuild
  home.activation.claudePluginsSync = lib.hm.dag.entryAfter [ "claudeSettings" ] ''
    ${syncPlugins}/bin/claude-plugins-sync || echo "[claude-plugins] sync failed, continuing"
  '';

  home.file.".claude/mcp.json".source = "${claudeDir}/mcp.json";
  home.file."CLAUDE.md".source = "${claudeDir}/CLAUDE.md";
}
