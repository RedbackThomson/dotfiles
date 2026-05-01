{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.utilities.enable {
    home.packages = with pkgs; [
      vhs
      viddy
      cloc
      ncdu
    ];
  };
}
