# Hyper Key + Aerospace + Unified Keymap Design

**Date:** 2026-04-16
**Status:** Draft
**Scope:** Karabiner-Elements (Hyper key), Aerospace TWM, Ghostty→tmux keybinds, keymap unification

## Problem

Current CapsLock→Ctrl+Space remap is Ghostty-specific, fragile (known CapsLock bug), and doesn't scale beyond tmux. Phase 3 adds Aerospace TWM which needs its own modifier layer. The full keymap (Aerospace, tmux, neovim) must coexist ergonomically without conflicts.

## Design Principles

- **Thumb-first:** primary modifiers (Cmd, Alt) are thumb keys — avoid pinky-heavy combos
- **One layer per modifier:** each modifier owns one scope, no overlap
- **Context-appropriate:** terminal bindings stay in Ghostty, OS bindings stay in Aerospace
- **macOS-native feel:** Cmd+T = new tab, Cmd+W = close, Cmd+1 = tab 1

## Physical Key Roles

| Physical key | Role | Managed by |
|---|---|---|
| **CapsLock (hold)** | Hyper (Cmd+Ctrl+Opt+Shift) — reserved, no bindings yet | Karabiner-Elements |
| **Left Alt + key** | Aerospace TWM (workspaces, window tiling) | Aerospace config |
| **Right Alt + key** | macOS special characters (€, accents) — unchanged | macOS default |
| **Cmd + key** | tmux operations + pane nav (Ghostty only) | Ghostty keybinds |
| **Ctrl + h/j/k/l** | vim-tmux-navigator (sent by Ghostty from Cmd+hjkl) | tmux + neovim plugin |
| **Space** | neovim leader | LazyVim (unchanged) |

## Layer 1: Aerospace (Left Alt)

**Limitation:** Aerospace cannot distinguish left_alt from right_alt (nikitabobko/AeroSpace#28). Both physical Alt keys produce the same `alt` modifier in Aerospace.

**Workaround:** Karabiner remaps `left_option` → `left_control + left_option`. Aerospace binds `ctrl+alt-*` combos. Physically you press left Alt (thumb) + key. Right Alt stays untouched — macOS special characters (€, accents) work normally.

Note: French accent dead keys (Option+E, Option+`, Option+I, Option+U, Option+N) don't conflict with any Aerospace binding — they work from either Alt key regardless.

### Bindings

In Aerospace config, these use `ctrl+alt` as modifier (triggered by physical left Alt via Karabiner):

| Physical combo | Aerospace binding | Command | Notes |
|---|---|---|---|
| `lalt-h/j/k/l` | `ctrl+alt-h/j/k/l` | `focus (left/down/up/right)` | vim-style directional focus |
| `lalt-shift-h/j/k/l` | `ctrl+alt+shift-h/j/k/l` | `move (left/down/up/right)` | Move focused window |
| `lalt-1` through `lalt-9` | `ctrl+alt-1` through `ctrl+alt-9` | `workspace 1` through `9` | Switch workspace |
| `lalt-shift-1` through `lalt-shift-9` | `ctrl+alt+shift-1` through `9` | `move-node-to-workspace 1` through `9` | Send window to workspace |
| `lalt-f` | `ctrl+alt-f` | `fullscreen` | Toggle fullscreen |
| `lalt-shift-f` | `ctrl+alt+shift-f` | `layout floating tiling` | Toggle float |
| `lalt-/` | `ctrl+alt-slash` | `layout tiles horizontal vertical` | Cycle tile orientation |
| `lalt-,` | `ctrl+alt-comma` | `layout accordion horizontal vertical` | Cycle accordion orientation |
| `lalt-minus` | `ctrl+alt-minus` | `resize smart -50` | Shrink |
| `lalt-equal` | `ctrl+alt-equal` | `resize smart +50` | Grow |
| `lalt-tab` | `ctrl+alt-tab` | `workspace-back-and-forth` | Toggle previous workspace |
| `lalt-shift-tab` | `ctrl+alt+shift-tab` | `move-workspace-to-monitor --wrap-around next` | Move workspace to next monitor |
| `lalt-enter` | `ctrl+alt-enter` | `exec-and-forget open -a Ghostty` | Launch terminal |

### Window Rules

```toml
# Float system dialogs
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'

# Spotify to dedicated workspace
[[on-window-detected]]
if.app-id = 'com.spotify.client'
run = 'move-node-to-workspace M'
```

Window rules are a starting point — will evolve with usage.

### Config

- Format: TOML (`~/.config/aerospace/aerospace.toml` or `~/.aerospace.toml`)
- Normalizations enabled (flatten containers, opposite orientation for nesting)
- Gaps: start at 0, adjust later
- `start-at-login = true`
- `after-startup-command`: assign initial workspaces

## Layer 2: Ghostty → tmux (Cmd)

Ghostty intercepts Cmd+key combos and sends terminal escape sequences that trigger tmux actions. These only work inside Ghostty — Cmd retains normal macOS behavior in all other apps.

### Pane Navigation

| Combo | Ghostty sends | Effect |
|---|---|---|
| `cmd+h` | `\x08` (Ctrl+H) | vim-tmux-navigator left |
| `cmd+j` | `\x0a` (Ctrl+J) | vim-tmux-navigator down |
| `cmd+k` | `\x0b` (Ctrl+K) | vim-tmux-navigator up |
| `cmd+l` | `\x0c` (Ctrl+L) | vim-tmux-navigator right |

This reuses the existing vim-tmux-navigator plugin — seamless navigation between neovim splits and tmux panes. Physical key is Cmd (thumb) but the terminal sees Ctrl+hjkl.

### tmux Operations

| Combo | Ghostty sends | tmux action |
|---|---|---|
| `cmd+t` | `prefix + n` | New window |
| `cmd+w` | `prefix + x` | Close pane (with confirm) |
| `cmd+s` | `prefix + v` | Split vertical |
| `cmd+shift+s` | `prefix + s` | Split horizontal |
| `cmd+f` | `prefix + f` | Session switcher (tmux-sessionizer) |
| `cmd+n` | `prefix + :new-session` | New session (sends `\x00:new-session\n`) |
| `cmd+1` through `cmd+9` | `prefix + 1` through `prefix + 9` | Switch to window N |

Implementation: Ghostty keybinds send the tmux prefix (Ctrl+Space = `\x00`) followed by the action key. Example: `cmd+t` sends `\x00n` (prefix + n).

Note: `\x00` is Ctrl+Space (NUL character) which is the tmux prefix.

### macOS Cmd Shortcuts Lost Inside Ghostty

| Shortcut | macOS default | Replacement |
|---|---|---|
| Cmd+H | Hide app | Not needed in tiling WM |
| Cmd+T | New tab | Replaced: new tmux window |
| Cmd+W | Close tab | Replaced: close tmux pane |
| Cmd+N | New window | Replaced: new tmux session |
| Cmd+S | Save | Not applicable in terminal |
| Cmd+F | Find | Replaced: session switcher |
| Cmd+1-9 | Tab switching | Replaced: tmux window switching |
| Cmd+L | Address bar (browsers) | Only in Ghostty: pane nav right |

Cmd+C (copy), Cmd+V (paste), Cmd+Q (quit), Cmd+Z (undo) remain unbound — macOS defaults preserved.

## Layer 3: Karabiner-Elements

### CapsLock → Hyper

CapsLock held sends Cmd+Ctrl+Opt+Shift simultaneously. No bindings assigned yet — reserved for future global shortcuts.

```json
{
  "description": "CapsLock → Hyper (Cmd+Ctrl+Opt+Shift)",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "caps_lock",
        "modifiers": { "optional": ["any"] }
      },
      "to": [
        {
          "key_code": "left_shift",
          "modifiers": ["left_command", "left_control", "left_option"]
        }
      ]
    }
  ]
}
```

### Left Option → Ctrl+Option (Aerospace workaround)

Aerospace cannot distinguish left/right Alt. Karabiner remaps left_option so it always sends `left_control + left_option`. Aerospace binds `ctrl+alt-*` combos, which only fire from the physical left Alt. Right Alt stays pure Option for macOS special characters.

```json
{
  "description": "Left Option → Ctrl+Option (for Aerospace)",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "left_option",
        "modifiers": { "optional": ["any"] }
      },
      "to": [
        {
          "key_code": "left_option",
          "modifiers": ["left_control"]
        }
      ]
    }
  ]
}
```

Trade-off: left Alt no longer produces macOS special characters. Use right Alt for those.

## Layer 4: Neovim (unchanged)

- **Space (leader):** all LazyVim keybindings
- **Ctrl+h/j/k/l:** vim-tmux-navigator (plugin unchanged, just triggered via Cmd now)
- No neovim config changes required

## tmux Prefix Retention

The tmux prefix `C-space` stays configured. Reasons:
- SSH into remote machines with tmux — Ghostty Cmd keybinds don't reach remote tmux
- Fallback if Ghostty keybinds have issues
- Existing muscle memory still works

The Ghostty `ctrl+space=unbind` keybind is no longer needed (CapsLock no longer sends Ctrl+Space), but we keep it to ensure Ctrl+Space passes through to tmux cleanly if pressed directly.

## Files Changed

| File | Change |
|---|---|
| `files/karabiner/karabiner.json` | Replace CapsLock→Ctrl+Space with CapsLock→Hyper + add left_option→ctrl+option rule |
| `home/ghostty.nix` | Add all Cmd keybinds for tmux operations and pane nav |
| `home/tmux.nix` | No changes needed — prefix bindings stay for SSH/fallback |
| `hosts/macbook.nix` | Add `aerospace` to casks list |
| `files/aerospace/aerospace.toml` | **New:** full Aerospace config with Left Alt bindings |
| `home/aerospace.nix` | **New:** home-manager module to symlink aerospace config |
| `home/default.nix` | Import `aerospace.nix` |

## Files Unchanged

- `files/nvim/lua/plugins/tmux-navigator.lua` — Ctrl+hjkl bindings unchanged
- `files/nvim/lua/config/keymaps.lua` — no neovim keymap changes
- `home/shell.nix` — no shell changes

## Migration

1. Install Karabiner-Elements (already in casks) + update config
2. Install Aerospace (add to casks) + add config
3. Update Ghostty keybinds
4. `darwin-rebuild switch`
5. Open Aerospace, grant accessibility permissions
6. Test each layer independently

CapsLock bug should be resolved since we're replacing the hidutil/Ctrl+Space hack with a proper Karabiner Hyper remap.
