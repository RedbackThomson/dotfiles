{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: let
  cfg = config.myconfig.core.git;
in {
  config = lib.mkMerge [
    # Git configuration
    (lib.mkIf cfg.enable {
      # `programs.git` will generate the config file: ~/.config/git/config
      # to make git use this config file, `~/.gitconfig` should not exist!
      #
      #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
      home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        rm -f ${config.home.homeDirectory}/.gitconfig
      '';

      home.packages = with pkgs; [
        act # Run GitHub Actions locally
      ];

      programs.git = {
        enable = true;
        lfs.enable = true;

        ignores = [
          ".DS_Store"
          "shell.nix"
          ".vscode"
          ".jj"
          ".claude"
        ];

        includes = [
          # {
          #   # use diffrent email & name for work
          #   path = "~/work/.gitconfig";
          #   condition = "gitdir:~/work/";
          # }
        ];

        settings = {
          user.name = myvars.userfullname;
          user.email = myvars.useremail;

          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          merge.conflictStyle = "zdiff3";
          rebase.autostash = true;
          rebase.autosquash = true;

          url = {
            "git@github.com:" = {insteadOf = "https://github.com/";};
          };

          alias = {
            # common aliases
            br = "branch";
            co = "checkout";
            st = "status";
            ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
            ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
            cm = "commit -m"; # commit via `git cm <message>`
            ca = "commit -am"; # commit all changes via `git ca <message>`
            dc = "diff --cached";
            pf = "push --force-with-lease";
            pum = "pull upstream main";

            amend = "commit --amend -m"; # amend commit message via `git amend <message>`
            unstage = "reset HEAD --"; # unstage file via `git unstage <file>`
            merged = "branch --merged"; # list merged(into HEAD) branches via `git merged`
            unmerged = "branch --no-merged"; # list unmerged(into HEAD) branches via `git unmerged`
            nonexist = "remote prune origin --dry-run"; # list non-exist(remote) branches
          };
        };
      };

      # A syntax-highlighting pager in Rust(2019 ~ Now)
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          diff-so-fancy = true;
          line-numbers = true;
          true-color = "always";
          light = false;
          # features => named groups of settings, used to keep related settings organized
          # features = "";
        };
      };
    })

    # Jujutsu configuration
    (lib.mkIf cfg.jujutsu.enable {
      home.packages = with pkgs; [
        lazyjj # A simple TUI for jujutsu
      ];

      programs.jujutsu = {
        enable = true;

        settings = {
          user.name = myvars.userfullname;
          user.email = myvars.useremail;

          git = {
            auto-local-bookmark = true;
            sign-on-push = true;

            fetch = ["origin" "upstream"];
            push = "origin";

            # Don't include changes with the description containing "private:*"
            # in the commit history
            private-commits = "description(glob:'private:*')";
          };

          ui = {
            default-command = "l";
            conflict-marker-style = "git";
          };

          revset-aliases = {
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "closest_pushable(to)" = "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
          };

          aliases = {
            ",," = ["edit" "@+"];
            ".." = ["edit" "@-"];
            a = ["abandon"];
            c = ["commit"];
            clone = ["git" "clone" "--colocate"];
            e = ["edit"];
            f = ["git" "fetch"];
            fetch = ["git" "fetch"];
            init = ["git" "init" "--colocate"];
            l = ["log"];
            la  = [ "log" "--revisions" "::" ];
            lp  = [ "log" "--patch" ];
            lpa = [ "log" "--patch" "--revisions" "::" ];
            ls  = [ "log" "--summary" ];
            lsa = [ "log" "--summary" "--revisions" "::" ];
            r = ["rebase"];
            res = ["resolve"];
            p = ["git" "push"];
            push = ["git" "push"];
            s = ["squash"];
            si = ["squash" "interactive"];
            tug = ["bookmark" "move" "--from" "closest_bookmark(@)" "--to" "closest_pushable(@)"];
            u = ["undo"];
            w = ["show" "closest_bookmark(@)"];
          };
        };
      };
    })
  ];
}
