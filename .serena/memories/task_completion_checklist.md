# Task Completion Checklist

After modifying any `.nix` file:
1. `git add` any new files (flakes only see tracked files)
2. Run `darwin-rebuild build --flake ~/src/config#macbook` to validate
3. If build succeeds, commit with conventional commit message
4. Do NOT commit directly on `main` — use feature branches
5. Open a draft PR on GitHub when done
