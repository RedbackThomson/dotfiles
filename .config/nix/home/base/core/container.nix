{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose

    argocd
    fluxcd
    istioctl
    kind
    kubectl
    kubernetes-helm
    # Disabled until the installer fix is merged into nixpkgs
    # pkgs-unstable.kubeswitch
    tilt
  ];
}
