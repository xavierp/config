# mise Version Manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace nvm/rbenv with mise, managed declaratively via home-manager `programs.mise`.

**Architecture:** New `home/mise.nix` module declares mise + global tool versions. Remove nvm/rbenv sourcing and Nix terraform package from `shell.nix`. Wire up the import in `default.nix`.

**Tech Stack:** Nix (home-manager), mise

**Spec:** `docs/superpowers/specs/2026-04-17-mise-version-manager-design.md`

---

### Task 1: Create `home/mise.nix`

**Files:**
- Create: `home/mise.nix`

- [ ] **Step 1: Create the mise module**

```nix
{ pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      tools = {
        node = "25";
        ruby = "4";
        python = "3.14";
        terraform = "1";
      };
    };
  };
}
```

- [ ] **Step 2: Stage the file**

```bash
git add home/mise.nix
```

---

### Task 2: Remove nvm/rbenv sourcing and terraform package from `shell.nix`

**Files:**
- Modify: `home/shell.nix:4-27` (remove `terraform` from packages)
- Modify: `home/shell.nix:52-58` (remove nvm/rbenv sourcing block)

- [ ] **Step 1: Remove `terraform` from `home.packages`**

In `home/shell.nix`, remove the `terraform` line from the `home.packages` list. The dev tools block should become:

```nix
    # Dev tools
    awscli2
    terragrunt
    tflint
    gh
    difftastic
```

- [ ] **Step 2: Remove nvm/rbenv sourcing from `initContent`**

In `home/shell.nix`, remove these lines from `initContent`:

```
      # Keep nvm working (installed outside Nix)
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # Keep rbenv working (installed outside Nix)
      eval "$(rbenv init - --no-rehash zsh)"
```

The `initContent` block should become:

```nix
    initContent = ''
      # Auto-attach to tmux session "main" (skip if already inside tmux)
      if [[ -z "$TMUX" && ("$TERM_PROGRAM" == "ghostty" || "$TERM" == "xterm-kitty") ]]; then
        exec tmux new-session -A -s main
      fi

      # Fix zsh glob errors on *, ?, [
      setopt NO_NOMATCH
    '';
```

- [ ] **Step 3: Commit**

```bash
git add home/mise.nix home/shell.nix
git commit -m "feat: add mise module, remove nvm/rbenv sourcing and nix terraform"
```

---

### Task 3: Wire up import in `home/default.nix`

**Files:**
- Modify: `home/default.nix:4-14` (add `./mise.nix` to imports)

- [ ] **Step 1: Add mise.nix to imports**

In `home/default.nix`, add `./mise.nix` to the imports list:

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
    ./kitty.nix
    ./mise.nix
  ];
```

- [ ] **Step 2: Commit**

```bash
git add home/default.nix
git commit -m "feat: import mise module in home-manager"
```

---

### Task 4: Rebuild and validate

- [ ] **Step 1: Rebuild**

```bash
sudo darwin-rebuild switch --flake ~/src/config#macbook
```

Expected: build succeeds, no errors.

- [ ] **Step 2: Verify mise is active**

```bash
which mise
mise doctor
```

Expected: mise found in Nix profile path, `mise doctor` reports no critical issues.

- [ ] **Step 3: Verify tool versions**

```bash
mise ls
node --version
ruby --version
python3 --version
terraform --version
```

Expected: mise manages all four tools, versions resolve to latest patch of Node 25, Ruby 4, Python 3.14, Terraform 1.

- [ ] **Step 4: Test project-level override**

Create a temp test:

```bash
cd /tmp && mkdir mise-test && cd mise-test
echo "22" > .nvmrc
mise install
node --version
```

Expected: Node 22.x.x (not 25). Clean up after: `rm -rf /tmp/mise-test`

- [ ] **Step 5: Commit spec and plan, open draft PR**

```bash
git add docs/superpowers/specs/2026-04-17-mise-version-manager-design.md
git add docs/superpowers/plans/2026-04-17-mise-version-manager.md
git commit -m "docs: add mise migration spec and implementation plan"
```

Then create a feature branch from main and open a draft PR with all commits.
