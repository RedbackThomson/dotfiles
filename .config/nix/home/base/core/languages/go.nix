{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  myvars,
  ...
}: {
  config = lib.mkIf config.myconfig.languages.go.enable {
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

    programs.zsh.initContent = ''
      # Go environment setup
      export GOBIN=$HOME/.local/bin
      export PATH=$GOBIN:$PATH
      mkdir -p $GOBIN
    '';
  };
}
