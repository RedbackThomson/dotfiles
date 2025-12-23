{lib, ...}: {
  options.myconfig.core = {
    # Essential tools - enabled by default for backwards compatibility
    essential.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Essential CLI tools (ripgrep, fd, fzf, bat, eza, zoxide, atuin)";
    };

    # Container/K8s tools (split into basic and advanced)
    containers = {
      basic.enable = lib.mkEnableOption "Basic container/K8s tools (kubectl, helm, k9s)";
      advanced.enable = lib.mkEnableOption "Advanced K8s tools (argocd, fluxcd, istio, tilt, cosign, trivy)";
    };

    # Cloud provider CLIs (individually optional)
    cloudProviders = {
      aws.enable = lib.mkEnableOption "AWS CLI and tools";
      gcp.enable = lib.mkEnableOption "Google Cloud SDK";
      azure.enable = lib.mkEnableOption "Azure CLI";
      digitalocean.enable = lib.mkEnableOption "DigitalOcean CLI";
    };

    # DevOps and utility tools
    devops.enable = lib.mkEnableOption "DevOps tools (terraform, earthly)";
    utilities.enable = lib.mkEnableOption "Utility tools (neofetch, vhs, viddy, cloc, ncdu)";
  };
}
