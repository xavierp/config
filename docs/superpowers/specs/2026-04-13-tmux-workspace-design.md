# tmux-centric workspace

## Problem

Multiple projects/worktrees open simultaneously (3-4 Pretto worktrees + 2-3 side projects) with frequent switching. No clear model for which layer handles what (Ghostty tabs vs tmux sessions vs macOS Spaces).

## Decision

Single layer: tmux manages everything. Ghostty is a dumb terminal that auto-launches tmux. No Ghostty tabs, no macOS Spaces for project separation.

## Architecture

### Session hierarchy

- **"main" session** — default on Ghostty launch, for quick commands
- **Project sessions** — one per project/worktree, named after directory (e.g., "pretto-auth", "config")
- **Windows** — nvim, terminal(s), claude as needed within each session
- **Panes** — occasional splits within a window

### Flow

1. Open Ghostty → auto-attached to tmux session "main"
2. `prefix + f` → fuzzy picker (fzf) to create/switch sessions
3. `prefix + f` again → switch to any other session
4. Close Ghostty → tmux persists, reattach on next open

### Config changes

#### Ghostty (`home/ghostty.nix`)

- Add: `command = tmux new-session -A -s main`
- Remove Ghostty tab-related keybinds if any

#### tmux keybinds (`home/tmux.nix`)

| Keybind | Action | Notes |
|---------|--------|-------|
| `prefix + v` | Split vertical | Unchanged |
| `prefix + s` | Split horizontal | Unchanged |
| `prefix + n` | New window | Was `prefix + c` |
| `prefix + f` | Fuzzy session switcher | New — runs sessionizer |
| `prefix + o` | Cycle panes | Default tmux, unchanged |
| `prefix + H/J/K/L` | Resize panes | Unchanged |
| `prefix + r` | Reload config | Unchanged |

#### Sessionizer script (`files/scripts/tmux-sessionizer`)

Shell script invoked by `prefix + f`:

1. List directories from configured paths (`~/src/`) via `find` depth 1
2. Pipe to `fzf` for fuzzy selection
3. If session exists for selected dir → `tmux switch-client`
4. If not → `tmux new-session -d -s <name> -c <path>`, then switch

Session name = basename of directory (sanitized: dots/spaces replaced).

#### Unchanged

- tmux resurrect + continuum (already configured, sessions persist across reboots)
- vim-tmux-navigator (Ctrl+h/j/k/l pane navigation)
- CapsLock → tmux prefix (F13 → Ghostty NUL byte)
