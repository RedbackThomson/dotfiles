{
  lib,
  pkgs,
  ...
}: {
  myconfig = {
    core = {
      git.enable = true;
      git.jujutsu.enable = true;
      ai.enable = true;
      utilities.enable = true;
      containers.basic.enable = true;
    };
  };

  home.packages = with pkgs; [
    claude-code
    gh # forge CLI; authenticates via GH_TOKEN from agenix (see initContent)
  ];

  # Push over SSH with the host's own key instead of a forwarded agent, which
  # dies when the laptop sleeps and would break long agent runs. The public
  # half must be added to GitHub; the private half is the agenix secret.
  programs.ssh.settings."github.com" = {
    IdentityFile = "/run/agenix/devbox-git-key";
    IdentitiesOnly = true;
  };

  # mkOrder 2000 runs after the shared ai module's `claude` wrapper (mkAfter =
  # 1500) so this definition wins. The shared one reads GH_TOKEN from 1Password
  # via `op`, which is not present headless; here the token comes from agenix
  # and is already in the environment, so `command claude` inherits it.
  #
  # zellij auto-attach makes a long-running process survive a client
  # disconnect: reconnecting over SSH drops straight back into `main`.
  programs.zsh.initContent = lib.mkOrder 2000 ''
    if [[ -r /run/agenix/gh-token ]]; then
      export GH_TOKEN="$(< /run/agenix/gh-token)"
    fi

    claude() {
      command claude "$@"
    }

    if [[ -z "$ZELLIJ" && -n "$SSH_CONNECTION" && $- == *i* && "$TERM" != "dumb" ]]; then
      zellij attach --create main
    fi
  '';

  home.shellAliases = {
    za = "zellij attach --create main";
  };
}
