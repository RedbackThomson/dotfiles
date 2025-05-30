{
  xdg.configFile."kubeconfigs/ops.yaml".source = ./kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ./kubeswitch/switch-config.yaml;
}
