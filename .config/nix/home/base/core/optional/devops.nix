{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.devops.enable {
    home.packages = with pkgs; [
      terraform
      earthly
    ];
  };
}
