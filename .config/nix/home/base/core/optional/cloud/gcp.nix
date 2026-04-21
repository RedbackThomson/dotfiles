{
  config,
  lib,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.myconfig.core.cloudProviders.gcp.enable {
    home.packages = with pkgs-unstable; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cloud-sql-proxy
      ])
    ];

    programs.zsh.initContent = ''
      export CLOUDSDK_PYTHON_SITEPACKAGES=1
    '';
  };
}
