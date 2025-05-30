# ... existing code from home/base/core/languages/go.nix ...
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
    golangci-lint
    pkgs-unstable.goreleaser
  ];

  programs.go = {
    enable = true;
    package = pkgs.go_1_23;
    goPrivate = ["github.com/upbound"];
  };

  programs.zsh.initExtra = ''
    export GOROOT=$(go env GOROOT)
    export GOPATH=$(go env GOPATH)
    export GOBIN=$GOPATH/bin
    export PATH="$GOBIN:$PATH"
  '';
}
