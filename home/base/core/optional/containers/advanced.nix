{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.myconfig.core.containers.advanced.enable {
    home.packages = with pkgs; [
      argocd
      fluxcd
      istioctl
      tilt
      cosign
      lazydocker
      trivy
    ];
  };
}
