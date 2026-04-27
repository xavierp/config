# Nix Dotfiles Phase 1 Implementation Plan

> **Status: COMPLETE** — All tasks done. System bootstrapped with nix-darwin + home-manager, shell, git, ghostty, claude configs, and casks.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Set up nix-darwin + home-manager on macOS to declaratively manage shell, CLI tools, git, ghostty, and Claude Code configs.

**Architecture:** Single Nix flake with nix-darwin (system-level: casks, keyboard remap) and home-manager as a module (user-level: zsh, git, tools). Hybrid approach — Nix for CLI tools, Homebrew casks piloted by nix-darwin for GUI apps.

**Tech Stack:** Nix flakes, nix-darwin, home-manager, nixpkgs unstable, zsh, starship

**Machine:** MacBook Pro Apple Silicon (aarch64-darwin), macOS 14.3, hostname `MacBook-Pro-du-X`

---

## File Structure

```
config/
├── flake.nix              # inputs + darwinConfigurations."macbook"
├── hosts/
│   └── macbook.nix        # nix-darwin system config
├── home/
│   ├── default.nix        # home-manager entry point
│   ├── shell.nix          # zsh + CLI tools + aliases
│   ├── git.nix            # git config
│   ├── ghostty.nix        # ghostty terminal config
│   └── claude.nix         # claude code config symlinks
├── files/
│   └── claude/
│       ├── settings.json
│       └── mcp.json
└── docs/
    └── cheatsheet.md
```

---

### Task 1: Install Nix

**Files:** None (system install)

- [x] **Step 1: Install Nix via Determinate Systems installer**

Run in a separate terminal (interactive — requires sudo):

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Follow the prompts. This installs Determinate Nix with flakes enabled by default.

- [x] **Step 2: Open a new terminal and verify Nix works**

Run: `nix --version`
Expected: `nix (Determinate Nix) 2.x.x` (any recent version)

Run: `nix run nixpkgs#hello`
Expected: `Hello, world!`

- [x] **Step 3: Commit**

No file changes — this is a system install. Just verify it works and move on.

---

### Task 2: Minimal flake with nix-darwin bootstrap

**Files:**
- Create: `flake.nix`
- Create: `hosts/macbook.nix`
- Create: `home/default.nix`

- [x] **Step 1: Create flake.nix**

```nix
{
  description = "Xavier's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macbook.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.x = import ./home/default.nix;
        }
      ];
    };
  };
}
```

- [x] **Step 2: Create hosts/macbook.nix (minimal)**

```nix
{ pkgs, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (minimal for bootstrap)
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Required for nix-darwin
  system.stateVersion = 6;

  # User
  users.users.x = {
    name = "x";
    home = "/Users/x";
  };
}
```

- [x] **Step 3: Create home/default.nix (minimal)**

```nix
{ pkgs, ... }:

{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

- [x] **Step 4: Build and activate nix-darwin for the first time**

Run from the repo root:

```bash
nix run nix-darwin -- switch --flake .
```

Note: the first run uses `nix run nix-darwin --` because `darwin-rebuild` is not yet in PATH. Subsequent runs use `darwin-rebuild switch --flake .`.

Expected: build succeeds, no errors. May ask for sudo password.

- [x] **Step 5: Verify darwin-rebuild is now available**

Open a new terminal.

Run: `darwin-rebuild --help`
Expected: help output from darwin-rebuild

Run: `which darwin-rebuild`
Expected: a path inside `/run/current-system/` or similar

- [x] **Step 6: Commit**

```bash
git add flake.nix flake.lock hosts/macbook.nix home/default.nix
git commit -m "feat: bootstrap nix-darwin with home-manager"
```

---

### Task 3: Zsh configuration via home-manager

**Files:**
- Create: `home/shell.nix`
- Modify: `home/default.nix`

- [x] **Step 1: Create home/shell.nix**

```nix
{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 1000000000;
      save = 1000000000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      append = true;
    };

    initExtra = ''
      # Fix zsh glob errors on *, ?, [
      setopt NO_NOMATCH
    '';

    shellAliases = {
      dk = "docker";
      dkc = "docker compose";
      g = "git";
      tf = "terraform";
    };
  };
}
```

- [x] **Step 2: Import shell.nix in home/default.nix**

Replace the contents of `home/default.nix` with:

```nix
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

- [x] **Step 3: Rebuild and verify**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds

Open a new terminal. Type a command you previously ran — you should see a gray autosuggestion appear (zsh-autosuggestions). Type an invalid command — it should appear red (syntax-highlighting).

Run: `echo $HISTSIZE`
Expected: `1000000000`

Run: `setopt | grep nomatch`
Expected: no output (NO_NOMATCH is set, so `nomatch` should NOT appear)

- [x] **Step 4: Commit**

```bash
git add home/shell.nix home/default.nix
git commit -m "feat: add zsh configuration with autosuggestions and syntax highlighting"
```

---

### Task 4: Modern CLI tools

**Files:**
- Modify: `home/shell.nix`

- [x] **Step 1: Add packages and tool integrations to home/shell.nix**

Replace the contents of `home/shell.nix` with:

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Modern replacements
    bat          # cat replacement with syntax highlighting
    eza          # ls replacement with icons and git
    fd           # find replacement
    ripgrep      # grep replacement
    tldr         # simplified man pages

    # Utilities
    jq
    yq-go
    wget
    tree
    watch
    gnused

    # Dev tools
    awscli2
    terraform
    terragrunt
    tflint
    neovim
    gh
    difftastic
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 1000000000;
      save = 1000000000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      append = true;
    };

    initExtra = ''
      # Fix zsh glob errors on *, ?, [
      setopt NO_NOMATCH

      # Keep nvm working (installed outside Nix)
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # Keep rbenv working (installed outside Nix)
      eval "$(rbenv init - --no-rehash zsh)"
    '';

    shellAliases = {
      # Shortcuts
      dk = "docker";
      dkc = "docker compose";
      g = "git";
      tf = "terraform";

      # Modern replacements
      cat = "bat";
      ls = "eza -1 --icons";
      ll = "eza -alh --icons --git";
      grep = "rg";
      find = "fd";
    };
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf (fuzzy finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Ctrl+T: file picker, Ctrl+R: history, Alt+C: cd
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # Direnv (per-directory env)
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

      directory.style = "blue";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };
}
```

- [x] **Step 2: Rebuild and verify tools**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds (may take a while downloading packages first time)

Open a new terminal and test each tool:

```bash
bat --version          # Expected: bat 0.x.x
eza --version          # Expected: eza - A modern, maintained replacement for ls
fd --version           # Expected: fd 10.x.x
rg --version           # Expected: ripgrep 14.x.x
z --help               # Expected: zoxide help output (or "zoxide: no match found" if no history yet)
fzf --version          # Expected: 0.x.x
direnv version         # Expected: 2.x.x
tldr --version         # Expected: some version output
terraform --version    # Expected: Terraform v1.x.x
aws --version          # Expected: aws-cli/2.x.x
```

Test fzf integration:
- Press `Ctrl+R` — should open fuzzy history search
- Press `Ctrl+T` — should open fuzzy file picker
- Type `ls **` then press `Tab` — should trigger fzf completion

Test zoxide:
- `cd /tmp && cd ~ && z tmp` — should take you to `/tmp`

Test aliases:
- `cat flake.nix` — should show syntax-highlighted output (bat)
- `ls` — should show icons (eza)
- `ll` — should show detailed listing with git status

- [x] **Step 3: Commit**

```bash
git add home/shell.nix
git commit -m "feat: add modern CLI tools (zoxide, fzf, bat, eza, ripgrep, fd, direnv, starship)"
```

---

### Task 5: Git configuration

**Files:**
- Create: `home/git.nix`
- Modify: `home/default.nix`

- [x] **Step 1: Create home/git.nix**

```nix
{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Xavier Pechot";
    userEmail = "xavp75@gmail.com";

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQOiPmr0zHIF+AgZ7T8KwDtClG41Sbh7jW+YadcYvNM";
      signByDefault = true;
      format = "ssh";
    };

    extraConfig = {
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      extensions.worktreeConfig = true;

      diff = {
        tool = "difftastic";
        external = "difft";
      };

      difftool = {
        prompt = false;
        difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
      };

      pager.difftool = true;
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    aliases = {
      # Status
      s = "status -s";
      contrib = "shortlog --summary --numbered";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";

      # Find
      fib = "!f() { git branch -a --contains $1; }; f";
      fit = "!f() { git describe --always --contains $1; }; f";
      fic = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short -S$1; }; f";
      fim = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f";
      ls = "ls-files";

      # Diff
      d = "diff";
      di = "! d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d";

      # Fetch and pull
      f = "fetch";
      ft = "fetch";
      p = "! git pull; git submodule foreach git pull origin master";

      # Add & commit
      ai = "add -p";
      ci = "commit";
      ca = "!git add -A && git commit -av";
      amend = "commit --amend --reuse-message=HEAD";
      wip = "!git add . && git ci -m 'WIP'";
      fix = "commit --amend --no-edit";
      credit = "!f() { git commit --amend --author \"$1 <$2>\" -C HEAD; }; f";

      # Push
      pub = "push -u origin HEAD";
      acpf = "! git add -A && git commit --amend --no-edit && git pub -f";

      # Checkout
      co = "checkout";
      coi = "checkout -p";

      # Branches
      br = "branch";
      branches = "branch -a";
      remotes = "remote -v";
      go = ''!f() { git checkout -b "$1" 2> /dev/null || git checkout "$1"; }; f'';
      dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";

      # Tags
      tags = "tag -l";
      retag = "!r() { git tag -d $1 && git push origin :refs/tags/$1 && git tag $1; }; r";

      # Rebase
      rb = "rebase";
      rbi = "rebase -i";
      reb = "!r() { git rebase -i HEAD~$1; }; r";
      rbc = "rebase --continue";
      rba = "rebase --abort";

      # Reset
      rz = "reset";
      fhr = "!git fetch origin && git reset --hard origin/master";
    };
  };
}
```

- [x] **Step 2: Add import in home/default.nix**

Replace the contents of `home/default.nix` with:

```nix
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

- [x] **Step 3: Rebuild and verify**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds

Run: `git config user.name`
Expected: `Xavier Pechot`

Run: `git config commit.gpgsign`
Expected: `true`

Run: `git config alias.lg`
Expected: the log alias format string

Run: `git log --oneline -3` in any repo with history — verify it still works normally.

- [x] **Step 4: Commit**

```bash
git add home/git.nix home/default.nix
git commit -m "feat: add declarative git configuration with signing and aliases"
```

---

### Task 6: Homebrew casks declaration

**Files:**
- Modify: `hosts/macbook.nix`

- [x] **Step 1: Add homebrew casks to hosts/macbook.nix**

Replace the contents of `hosts/macbook.nix` with:

```nix
{ pkgs, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Keyboard
  system.keyboard.remapCapsLockToControl = true;

  # Homebrew (for GUI apps / casks only)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    casks = [
      "1password"
      "alacritty"
      "bruno"
      "chromium"
      "dash"
      "datagrip"
      "discord"
      "docker"
      "docker-desktop"
      "firefox"
      "font-fira-code"
      "ghostty"
      "gimp"
      "google-chrome"
      "jellyfin-media-player"
      "macfuse"
      "nordvpn"
      "obsidian"
      "protonvpn"
      "raycast"
      "session-manager-plugin"
      "sigmaos"
      "slack"
      "soulseek"
      "spotify"
      "tor-browser"
      "visual-studio-code"
      "vlc"
      "whatsapp"
    ];
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # Required for nix-darwin
  system.stateVersion = 6;

  # User
  users.users.x = {
    name = "x";
    home = "/Users/x";
  };
}
```

- [x] **Step 2: Rebuild and verify**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds. Homebrew may take a while the first time as it reconciles the cask list. You should NOT see any casks being uninstalled that you still use — if you do, abort (`Ctrl+C`) and check the list.

Verify Caps Lock is remapped: press Caps Lock + C in terminal — should act as Ctrl+C (interrupt).

Run: `brew list --cask | wc -l`
Expected: count matching the cask list above (approximately 29)

- [x] **Step 3: Commit**

```bash
git add hosts/macbook.nix
git commit -m "feat: add homebrew casks declaration and caps lock remap"
```

---

### Task 7: Ghostty configuration

**Files:**
- Create: `home/ghostty.nix`
- Modify: `home/default.nix`

- [x] **Step 1: Create home/ghostty.nix**

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
  '';
}
```

- [x] **Step 2: Add import in home/default.nix**

Replace the contents of `home/default.nix` with:

```nix
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

- [x] **Step 3: Rebuild and verify**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds

Run: `cat ~/.config/ghostty/config | head -5`
Expected: shows `# Theme` and `theme = nord` — the file is now managed by Nix

Open a new Ghostty window — should look identical to before (same theme, font, opacity).

- [x] **Step 4: Commit**

```bash
git add home/ghostty.nix home/default.nix
git commit -m "feat: add ghostty terminal configuration"
```

---

### Task 8: Claude Code configuration

**Files:**
- Create: `files/claude/settings.json`
- Create: `files/claude/mcp.json`
- Create: `home/claude.nix`
- Modify: `home/default.nix`

- [x] **Step 1: Copy current Claude Code configs to repo**

```bash
cp ~/.claude/settings.json files/claude/settings.json
cp ~/.claude/mcp.json files/claude/mcp.json
```

- [x] **Step 2: Create home/claude.nix**

```nix
{ ... }:

let
  claudeDir = ../files/claude;
in
{
  home.file.".claude/settings.json".source = "${claudeDir}/settings.json";
  home.file.".claude/mcp.json".source = "${claudeDir}/mcp.json";
}
```

- [x] **Step 3: Add import in home/default.nix**

Replace the contents of `home/default.nix` with:

```nix
{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./claude.nix
  ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

- [x] **Step 4: Rebuild and verify**

Run: `darwin-rebuild switch --flake .`
Expected: build succeeds

Run: `ls -la ~/.claude/settings.json`
Expected: symlink pointing to `/nix/store/...-home-manager-files/.claude/settings.json`

Run: `cat ~/.claude/settings.json`
Expected: same content as before — Claude Code should work normally.

**Important:** If home-manager complains that `~/.claude/settings.json` already exists and is not a symlink, you need to back up and remove the originals first:

```bash
mv ~/.claude/settings.json ~/.claude/settings.json.bak
mv ~/.claude/mcp.json ~/.claude/mcp.json.bak
darwin-rebuild switch --flake .
```

- [x] **Step 5: Commit**

```bash
mkdir -p files/claude
git add files/claude/settings.json files/claude/mcp.json home/claude.nix home/default.nix
git commit -m "feat: add Claude Code configuration management"
```

---

### Task 9: Cheatsheet

**Files:**
- Create: `docs/cheatsheet.md`

- [x] **Step 1: Create docs/cheatsheet.md**

```markdown
# Cheatsheet — Modern CLI & Nix

## Rebuild config

```bash
darwin-rebuild switch --flake ~/src/config    # appliquer les changements
nix flake update                               # mettre a jour nixpkgs, home-manager, nix-darwin
nix-collect-garbage -d                         # nettoyer le nix store manuellement
```

## Navigation (zoxide)

| Commande | Action |
|---|---|
| `z foo` | Sauter dans le dossier le plus frequent contenant "foo" |
| `z foo bar` | Affiner avec plusieurs mots |
| `zi foo` | Mode interactif (fzf) |

## Fuzzy finder (fzf)

| Raccourci | Action |
|---|---|
| `Ctrl+R` | Recherche fuzzy dans l'historique |
| `Ctrl+T` | Picker de fichiers (insere le chemin) |
| `Alt+C` | cd fuzzy dans un sous-dossier |
| `**<Tab>` | Completion fuzzy (ex: `vim **<Tab>`) |

## Recherche

| Commande | Action |
|---|---|
| `rg "pattern"` | Chercher dans les fichiers (ripgrep) |
| `rg "pattern" -t ruby` | Chercher seulement dans les fichiers Ruby |
| `rg "pattern" -l` | Lister seulement les fichiers qui matchent |
| `fd "pattern"` | Trouver des fichiers par nom |
| `fd -e rb` | Trouver les fichiers .rb |
| `fd "pattern" --type d` | Trouver des dossiers |

## Visualisation

| Commande | Action |
|---|---|
| `bat fichier.rb` | cat avec syntax highlighting |
| `bat -l json` | Forcer le langage |
| `eza -alh --git` | ls detaille avec statut git |
| `eza --tree --level=2` | Arborescence |
| `tldr tar` | Pages man simplifiees |

## Direnv

| Commande | Action |
|---|---|
| `echo "use nix" > .envrc` | Creer un env Nix par projet |
| `direnv allow` | Autoriser le .envrc du dossier courant |
| `direnv deny` | Revoquer l'autorisation |

## Git aliases

| Alias | Commande |
|---|---|
| `g s` | `git status -s` |
| `g lg` | Log graph colore |
| `g ai` | `git add -p` (interactive) |
| `g ci` | `git commit` |
| `g ca` | Add all + commit |
| `g pub` | Push + set upstream |
| `g co <branch>` | Checkout |
| `g go <branch>` | Checkout ou cree la branche |
| `g d` | Diff |
| `g dm` | Supprimer les branches mergees |
| `g amend` | Amend sans changer le message |
| `g wip` | Commit WIP rapide |

## Keyboard

| Touche | Action |
|---|---|
| `Caps Lock` | Agit comme `Ctrl` (remap systeme) |
| `Ctrl+Space` | Prefix tmux (phase 2) |
```

- [x] **Step 2: Commit**

```bash
git add docs/cheatsheet.md
git commit -m "docs: add CLI tools and shortcuts cheatsheet"
```

---

### Task 10: Cleanup old zshrc and push

**Files:**
- Modify: `~/.zshrc` (backup)
- Modify: `~/.zprofile` (backup)
- Modify: `~/.config/starship.toml` (backup)

- [x] **Step 1: Backup old dotfiles**

```bash
mkdir -p ~/dotfiles-backup
cp ~/.zshrc ~/dotfiles-backup/.zshrc.bak 2>/dev/null
cp ~/.zprofile ~/dotfiles-backup/.zprofile.bak 2>/dev/null
cp ~/.config/starship.toml ~/dotfiles-backup/starship.toml.bak 2>/dev/null
cp ~/.gitconfig ~/dotfiles-backup/.gitconfig.bak 2>/dev/null
```

- [x] **Step 2: Remove old configs that conflict with home-manager**

Home-manager manages `~/.zshrc`, `~/.config/starship.toml`, and `~/.config/git/config` via symlinks. If the old files still exist as regular files, home-manager will have warned during rebuild. Remove them only after verifying the Nix-managed versions work:

```bash
rm ~/.zshrc 2>/dev/null           # home-manager manages this now
rm ~/.config/starship.toml 2>/dev/null  # home-manager manages this now
```

Keep `~/.zprofile` for now — home-manager doesn't fully manage it and brew/rbenv/nvm may still need entries there. Keep `~/.gitconfig` only if home-manager didn't take it over (check if it's a symlink: `ls -la ~/.gitconfig`).

- [x] **Step 3: Rebuild one last time and verify everything**

Run: `darwin-rebuild switch --flake .`
Expected: clean build, no warnings about existing files

Open a new terminal and verify:
- Prompt shows starship (purple ❯)
- Autosuggestions work (gray text)
- Syntax highlighting works (valid = green, invalid = red)
- `z`, `fzf`, `bat`, `eza`, `rg`, `fd` all work
- `g s` works (git status)
- Caps Lock acts as Ctrl

- [x] **Step 4: Push to GitHub**

```bash
git push origin main
```

Expected: pushed to https://github.com/xavierp/config
