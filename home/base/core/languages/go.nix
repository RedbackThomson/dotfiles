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
      package = pkgs.go_1_26;
      env = {
        GOPRIVATE = "github.com/upbound";
        GOBIN = "${config.home.homeDirectory}/.local/bin";
      };
    };

    programs.zsh.initContent = ''
      export GOBIN=${config.home.homeDirectory}/.local/bin
      export PATH=$GOBIN:$PATH
      mkdir -p $GOBIN
    '';
  };
}
