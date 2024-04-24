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
    kubeswitch
    tilt
  ];
}
