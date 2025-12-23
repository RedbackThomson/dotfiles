{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myconfig.languages.python.enable {
    home.packages = with pkgs; [
      python3
      hatch
    ];
  };
}
