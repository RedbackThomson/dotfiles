{
  pkgs,
  _1password-shell,
  lib,
  ...
}: {
  imports = [_1password-shell.hmModules.default];

  programs._1password-shell-plugins = {
    enable = true;
    plugins = with pkgs; [ gh awscli2 ];
  };

  home.packages = [
    pkgs._1password
    pkgs._1password-gui
  ];
}
