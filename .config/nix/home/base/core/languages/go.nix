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
    gotools
    pkgs-unstable.goreleaser
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_24;
    goPrivate = ["github.com/upbound"];
  };
}
