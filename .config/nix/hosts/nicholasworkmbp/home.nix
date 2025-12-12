{ pkgs, ...}: {
  xdg.configFile."kubeconfigs/ops.yaml".source = ./kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ./kubeswitch/switch-config.yaml;

  home.packages = with pkgs; [
    stripe-cli

    # NATS CLI tools
    natscli
    nsc
  ];
}
