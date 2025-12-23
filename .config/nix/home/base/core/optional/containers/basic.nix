{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.containers.basic.enable {
    home.packages = with pkgs; [
      kubectl
      kubectl-neat
      kubernetes-helm
      kind
    ];
  };
}
