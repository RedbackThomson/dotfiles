{
  pkgs,
  _1password-shell,
  lib,
  myvars,
  ...
}: let
  opSshSign = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
in {
  imports = [_1password-shell.hmModules.default];

  home.packages = [
    pkgs._1password-cli
  ];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [gh];
  };

  programs.git = {
    settings = {
      commit.gpgsign = true;
      user.signingkey = myvars.signingkey;
      gpg = {
        format = "ssh";
        ssh.program = opSshSign;
      };
    };
  };

  programs.jujutsu.settings.signing = {
    backend = "ssh";
    key = myvars.signingkey;
    backends.ssh.program = opSshSign;
  };

  programs.ssh.extraConfig = ''
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  '';
}
