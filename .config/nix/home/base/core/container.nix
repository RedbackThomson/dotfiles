{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: {
  home.packages = with pkgs; [
    argocd
    fluxcd
    istioctl
    kind
    kubectl
    kubectl-neat
    kubernetes-helm
    # Disabled until the installer fix is merged into nixpkgs
    # pkgs-unstable.kubeswitch
    tilt
    cosign

    trivy
  ];
}
