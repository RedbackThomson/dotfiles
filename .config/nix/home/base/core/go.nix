{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  myvars,
  ...
}: {
  home.packages = with pkgs; [
    ko
  ];

  programs.go = {
    enable = true;
    package = pkgs-unstable.go_1_22;
    goPrivate = [ "github.com/upbound" ];
  };
}
