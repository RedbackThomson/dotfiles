{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.cloudProviders.gcp.enable {
    home.packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cloud-sql-proxy
      ])
    ];
  };
}
