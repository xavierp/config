{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQOiPmr0zHIF+AgZ7T8KwDtClG41Sbh7jW+YadcYvNM";
      signByDefault = true;
      format = "ssh";
    };

    settings = {
      user = {
        name = "Xavier Pechot";
        email = "xavp75@gmail.com";
      };

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

      alias = {
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
  };

  # Delta (git pager with syntax highlighting)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
