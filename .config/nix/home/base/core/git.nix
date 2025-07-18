{
  config,
  lib,
  pkgs,
  myvars,
  ...
}: {
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

    userName = myvars.userfullname;
    userEmail = myvars.useremail;

    ignores = [
      ".DS_Store"
      "shell.nix"
      ".vscode"
    ];

    includes = [
      # {
      #   # use diffrent email & name for work
      #   path = "~/work/.gitconfig";
      #   condition = "gitdir:~/work/";
      # }
    ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      merge.conflictStyle = "zdiff3";
      rebase.autostash = true;
      rebase.autosquash = true;

      url = {
        "git@github.com:" = {insteadOf = "https://github.com/";};
      };
    };

    # A syntax-highlighting pager in Rust(2019 ~ Now)
    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
        light = false;
        # features => named groups of settings, used to keep related settings organized
        # features = "";
      };
    };

    aliases = {
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

      amend = "commit --amend -m"; # amend commit message via `git amend <message>`
      unstage = "reset HEAD --"; # unstage file via `git unstage <file>`
      merged = "branch --merged"; # list merged(into HEAD) branches via `git merged`
      unmerged = "branch --no-merged"; # list unmerged(into HEAD) branches via `git unmerged`
      nonexist = "remote prune origin --dry-run"; # list non-exist(remote) branches via `git nonexist`
    };
  };
}
