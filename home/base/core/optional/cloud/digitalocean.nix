{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.cloudProviders.digitalocean.enable {
    home.packages = with pkgs; [
      doctl
    ];
  };
}
