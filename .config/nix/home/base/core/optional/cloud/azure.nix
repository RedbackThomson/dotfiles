{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.cloudProviders.azure.enable {
    home.packages = with pkgs; [
      azure-cli
    ];
  };
}
