{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myconfig.languages.kcl.enable {
    home.packages = with pkgs; [
      kcl
    ];
  };
}
