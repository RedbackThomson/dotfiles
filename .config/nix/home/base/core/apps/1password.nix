{
  pkgs,
  _1password-shell,
  lib,
  myvars,
  ...
}: {
  imports = [_1password-shell.hmModules.default];

  home.packages = [
    pkgs._1password-cli
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh ];
  };

  programs.git = {
    extraConfig = {
      commit.gpgsign = true;
      user.signingkey = myvars.signingkey;
      gpg = {
        format = "ssh";
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };
  };

  programs.ssh = {
    forwardAgent = true;
    extraConfig = ''
      IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
