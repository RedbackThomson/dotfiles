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
    package = pkgs-unstable.go_1_22;
    goPrivate = [ "github.com/upbound" ];
  };

  programs.zsh.initExtra = ''
    export GOROOT=$(go env GOROOT)
    export GOPATH=$(go env GOPATH)
    export GOBIN=$GOPATH/bin
    export PATH="$GOBIN:$PATH"
  '';
}
