# Hyper Key + Aerospace + Unified Keymap Implementation Plan

> **Status: COMPLETE** — All tasks done. Hyper key (CapsLock), left Alt → Ctrl+Alt, Aerospace config ready (cask paused pending macOS Spaces tuning), Ghostty Cmd keybinds for tmux.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Replace the fragile CapsLock→Ctrl+Space hack with a proper Hyper key, add Aerospace TWM with Left Alt bindings, and add Cmd-based tmux shortcuts in Ghostty.

**Architecture:** Karabiner-Elements handles key remapping (CapsLock→Hyper, left_option→ctrl+option). Aerospace reads its own TOML config for tiling WM bindings using `ctrl+alt` modifier. Ghostty intercepts Cmd+key combos and sends escape sequences to tmux. All configs managed via Nix (home-manager).

**Tech Stack:** Nix/home-manager, Karabiner-Elements, Aerospace TWM, Ghostty, tmux

**Spec:** `docs/superpowers/specs/2026-04-16-hyper-aerospace-keymap-design.md`

---

### Task 1: Update Karabiner config (CapsLock→Hyper + left_option→ctrl+option)

**Files:**
- Modify: `files/karabiner/karabiner.json`

- [x] **Step 1: Replace karabiner.json with new rules**

Replace the entire content of `files/karabiner/karabiner.json` with:

```json
{
  "profiles": [
    {
      "name": "Default",
      "selected": true,
      "complex_modifications": {
        "rules": [
          {
            "description": "CapsLock → Hyper (Cmd+Ctrl+Opt+Shift)",
            "manipulators": [
              {
                "type": "basic",
                "from": {
                  "key_code": "caps_lock",
                  "modifiers": {
                    "optional": ["any"]
                  }
                },
                "to": [
                  {
                    "key_code": "left_shift",
                    "modifiers": ["left_command", "left_control", "left_option"]
                  }
                ]
              }
            ]
          },
          {
            "description": "Left Option → Ctrl+Option (for Aerospace left/right Alt distinction)",
            "manipulators": [
              {
                "type": "basic",
                "from": {
                  "key_code": "left_option",
                  "modifiers": {
                    "optional": ["any"]
                  }
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
        ]
      },
      "virtual_hid_keyboard": {
        "keyboard_type_v2": "ansi"
      }
    }
  ]
}
```

- [x] **Step 2: Verify JSON is valid**

Run: `cat files/karabiner/karabiner.json | jq .`
Expected: valid JSON output, no parse errors.

- [x] **Step 3: Commit**

```bash
git add files/karabiner/karabiner.json
git commit -m "feat: capslock hyper key + left option ctrl+option remap"
```

---

### Task 2: Create Aerospace config

**Files:**
- Create: `files/aerospace/aerospace.toml`

- [x] **Step 1: Create the aerospace config directory and file**

Run: `mkdir -p files/aerospace`

Create `files/aerospace/aerospace.toml` with:

```toml
# Aerospace TWM config
# Bindings use ctrl+alt (physical left Alt via Karabiner remap)
# Spec: docs/superpowers/specs/2026-04-16-hyper-aerospace-keymap-design.md

start-at-login = true

# Normalizations (recommended defaults)
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

# Mouse follows focus across monitors
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

# No gaps to start — adjust later
[gaps]
inner.horizontal = 0
inner.vertical = 0
outer.left = 0
outer.right = 0
outer.top = 0
outer.bottom = 0

# Main keybindings (ctrl+alt = physical left Alt via Karabiner)
[mode.main.binding]

# Focus window (vim-style)
ctrl-alt-h = 'focus left'
ctrl-alt-j = 'focus down'
ctrl-alt-k = 'focus up'
ctrl-alt-l = 'focus right'

# Move window
ctrl-alt-shift-h = 'move left'
ctrl-alt-shift-j = 'move down'
ctrl-alt-shift-k = 'move up'
ctrl-alt-shift-l = 'move right'

# Switch workspace
ctrl-alt-1 = 'workspace 1'
ctrl-alt-2 = 'workspace 2'
ctrl-alt-3 = 'workspace 3'
ctrl-alt-4 = 'workspace 4'
ctrl-alt-5 = 'workspace 5'
ctrl-alt-6 = 'workspace 6'
ctrl-alt-7 = 'workspace 7'
ctrl-alt-8 = 'workspace 8'
ctrl-alt-9 = 'workspace 9'

# Move window to workspace
ctrl-alt-shift-1 = ['move-node-to-workspace 1', 'workspace 1']
ctrl-alt-shift-2 = ['move-node-to-workspace 2', 'workspace 2']
ctrl-alt-shift-3 = ['move-node-to-workspace 3', 'workspace 3']
ctrl-alt-shift-4 = ['move-node-to-workspace 4', 'workspace 4']
ctrl-alt-shift-5 = ['move-node-to-workspace 5', 'workspace 5']
ctrl-alt-shift-6 = ['move-node-to-workspace 6', 'workspace 6']
ctrl-alt-shift-7 = ['move-node-to-workspace 7', 'workspace 7']
ctrl-alt-shift-8 = ['move-node-to-workspace 8', 'workspace 8']
ctrl-alt-shift-9 = ['move-node-to-workspace 9', 'workspace 9']

# Layout
ctrl-alt-f = 'fullscreen'
ctrl-alt-shift-f = 'layout floating tiling'
ctrl-alt-slash = 'layout tiles horizontal vertical'
ctrl-alt-comma = 'layout accordion horizontal vertical'

# Resize
ctrl-alt-minus = 'resize smart -50'
ctrl-alt-equal = 'resize smart +50'

# Workspace navigation
ctrl-alt-tab = 'workspace-back-and-forth'
ctrl-alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

# Launch terminal
ctrl-alt-enter = 'exec-and-forget open -a Ghostty'

# Window rules
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'com.spotify.client'
run = 'move-node-to-workspace M'
```

- [x] **Step 2: Commit**

```bash
git add files/aerospace/aerospace.toml
git commit -m "feat: add aerospace TWM config with ctrl+alt bindings"
```

---

### Task 3: Create Aerospace Nix module + add cask

**Files:**
- Create: `home/aerospace.nix`
- Modify: `home/default.nix`
- Modify: `hosts/macbook.nix`

- [x] **Step 1: Create home/aerospace.nix**

```nix
{ ... }:

{
  xdg.configFile."aerospace/aerospace.toml".source = ../files/aerospace/aerospace.toml;
}
```

- [x] **Step 2: Add aerospace import to home/default.nix**

Add `./aerospace.nix` to the imports list in `home/default.nix`:

```nix
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
    ./karabiner.nix
    ./tmux.nix
    ./neovim.nix
    ./aerospace.nix
  ];
```

- [x] **Step 3: Add aerospace to casks in hosts/macbook.nix**

Add `"aerospace"` to the `casks` list in `hosts/macbook.nix`, maintaining alphabetical order (insert before `"alacritty"`):

```nix
    casks = [
      "1password"
      "aerospace"
      "alacritty"
```

- [x] **Step 4: Commit**

```bash
git add home/aerospace.nix home/default.nix hosts/macbook.nix
git commit -m "feat: add aerospace nix module and cask"
```

---

### Task 4: Add Ghostty Cmd keybinds for tmux

**Files:**
- Modify: `home/ghostty.nix`

- [x] **Step 1: Add Cmd keybinds to ghostty.nix**

In `home/ghostty.nix`, add the following keybinds after the existing `keybind = ctrl+space=unbind` line:

```nix
    # Cmd+hjkl → Ctrl+hjkl for vim-tmux-navigator (thumb instead of pinky)
    keybind = cmd+h=text:\x08
    keybind = cmd+j=text:\x0a
    keybind = cmd+k=text:\x0b
    keybind = cmd+l=text:\x0c

    # Cmd → tmux operations (prefix is Ctrl+Space = \x00)
    keybind = cmd+t=text:\x00n
    keybind = cmd+w=text:\x00x
    keybind = cmd+s=text:\x00v
    keybind = cmd+shift+s=text:\x00s
    keybind = cmd+f=text:\x00f
    keybind = cmd+n=text:\x00:new-session\x0a
    keybind = cmd+1=text:\x001
    keybind = cmd+2=text:\x002
    keybind = cmd+3=text:\x003
    keybind = cmd+4=text:\x004
    keybind = cmd+5=text:\x005
    keybind = cmd+6=text:\x006
    keybind = cmd+7=text:\x007
    keybind = cmd+8=text:\x008
    keybind = cmd+9=text:\x009
```

- [x] **Step 2: Verify the full ghostty.nix looks correct**

The complete file should be:

```nix
{ ... }:

{
  xdg.configFile."ghostty/config".text = ''
    # Theme
    theme = nord

    # Font
    font-family = JetBrainsMono Nerd Font
    font-size = 12
    font-feature = calt
    font-feature = liga

    # Window
    window-height = 35
    window-width = 120
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    window-decoration = true
    background-opacity = 0.95

    # Cursor
    cursor-style = block
    cursor-style-blink = true

    # Behavior
    scrollback-limit = 10000
    copy-on-select = true
    confirm-close-surface = true
    clipboard-paste-protection = false

    # Shell integration
    shell-integration = detect
    shell-integration-features = cursor,sudo,title

    # Splits
    focus-follows-mouse = false

    # Force Ctrl+Space through to terminal (for tmux prefix)
    keybind = ctrl+space=unbind

    # Cmd+hjkl → Ctrl+hjkl for vim-tmux-navigator (thumb instead of pinky)
    keybind = cmd+h=text:\x08
    keybind = cmd+j=text:\x0a
    keybind = cmd+k=text:\x0b
    keybind = cmd+l=text:\x0c

    # Cmd → tmux operations (prefix is Ctrl+Space = \x00)
    keybind = cmd+t=text:\x00n
    keybind = cmd+w=text:\x00x
    keybind = cmd+s=text:\x00v
    keybind = cmd+shift+s=text:\x00s
    keybind = cmd+f=text:\x00f
    keybind = cmd+n=text:\x00:new-session\x0a
    keybind = cmd+1=text:\x001
    keybind = cmd+2=text:\x002
    keybind = cmd+3=text:\x003
    keybind = cmd+4=text:\x004
    keybind = cmd+5=text:\x005
    keybind = cmd+6=text:\x006
    keybind = cmd+7=text:\x007
    keybind = cmd+8=text:\x008
    keybind = cmd+9=text:\x009

    # Clickable links
    link-url = true
  '';
}
```

- [x] **Step 3: Commit**

```bash
git add home/ghostty.nix
git commit -m "feat: add cmd keybinds for tmux pane nav and operations"
```

---

### Task 5: Rebuild and verify

**Files:** none (verification only)

- [x] **Step 1: Git add all new files (flake requirement)**

Run: `git add -A`

New files must be tracked for Nix flakes to see them.

- [x] **Step 2: Rebuild**

Run: `sudo darwin-rebuild switch --flake ~/src/config#macbook`

Expected: build succeeds with no errors.

- [x] **Step 3: Verify Karabiner config was deployed**

Run: `cat ~/.config/karabiner/karabiner.json | jq '.profiles[0].complex_modifications.rules | length'`

Expected: `2` (Hyper rule + left_option rule)

- [x] **Step 4: Verify Aerospace config was deployed**

Run: `cat ~/.config/aerospace/aerospace.toml | head -5`

Expected: shows the Aerospace config header with `start-at-login = true`.

- [x] **Step 5: Verify Ghostty config has Cmd keybinds**

Run: `grep "cmd+" ~/.config/ghostty/config | wc -l`

Expected: `16` or more lines (4 hjkl + 3 operations + 9 window numbers)

- [x] **Step 6: Open Aerospace and grant accessibility permissions**

Aerospace needs macOS accessibility permissions on first launch. Open it from Applications or Spotlight, then go to System Settings → Privacy & Security → Accessibility → enable Aerospace.

- [x] **Step 7: Manual testing checklist**

Test each layer independently:

**Karabiner:**
- [x] Press CapsLock — should do nothing visible (Hyper with no bindings)
- [x] Press Right Alt + E then E — should produce é (accent works)
- [x] Press Left Alt + H — should trigger Aerospace focus left (if windows available)

**Aerospace:**
- [x] Left Alt + 1/2/3 — switch workspaces
- [x] Left Alt + Shift + H/J/K/L — move windows
- [x] Left Alt + F — fullscreen toggle
- [x] Left Alt + Enter — opens Ghostty

**Ghostty → tmux:**
- [x] Cmd + H/J/K/L — navigate tmux panes / neovim splits seamlessly
- [x] Cmd + T — new tmux window
- [x] Cmd + W — close tmux pane
- [x] Cmd + S — vertical split
- [x] Cmd + Shift + S — horizontal split
- [x] Cmd + F — session switcher
- [x] Cmd + 1-9 — switch tmux windows
- [x] Cmd + C/V/Q — still work as macOS defaults

**Preserved shortcuts:**
- [x] Cmd + Space — Raycast still works
- [x] Cmd + Shift + Space — 1Password still works

- [x] **Step 8: Final commit**

```bash
git add -A
git commit -m "feat: complete hyper key + aerospace + unified keymap setup"
git push
```

---

### Task 6: Update CLAUDE.md and cheatsheet

**Files:**
- Modify: `CLAUDE.md`
- Modify: `docs/cheatsheet.md`

- [x] **Step 1: Update CLAUDE.md critical quirks**

Add to the "Critical quirks" section in `CLAUDE.md`:

```markdown
- **CapsLock → Hyper**: Karabiner-Elements sends Cmd+Ctrl+Opt+Shift on CapsLock. No bindings yet — reserved for future use.
- **Left Alt → Ctrl+Alt**: Karabiner adds Ctrl to left_option presses so Aerospace can distinguish left/right Alt. Right Alt unchanged (special chars).
- **Aerospace TWM**: tiling window manager, binds `ctrl+alt-*` (physical left Alt + key). Config at `files/aerospace/aerospace.toml`.
- **Ghostty Cmd keybinds**: Cmd+hjkl sends Ctrl+hjkl (vim-tmux-navigator), Cmd+t/w/s/f/n/1-9 sends tmux prefix + action.
```

Remove or update the existing CapsLock quirk about Ctrl+Space.

- [x] **Step 2: Update docs/cheatsheet.md**

Add a keymap reference section if not present, covering all four layers (Aerospace, Ghostty→tmux, neovim, Hyper).

- [x] **Step 3: Commit**

```bash
git add CLAUDE.md docs/cheatsheet.md
git commit -m "docs: update CLAUDE.md and cheatsheet with new keymap"
git push
```
