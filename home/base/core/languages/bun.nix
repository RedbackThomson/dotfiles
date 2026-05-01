{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myconfig.languages.bun.enable {
    home.packages = with pkgs; [
      pkgs-unstable.bun
    ];
  };
}
