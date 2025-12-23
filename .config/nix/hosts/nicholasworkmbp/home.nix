{ pkgs, ...}: {
  myconfig.languages = {
    bun.enable = false;
    go.enable = true;
    rust.enable = false;
    python.enable = false;
    kcl.enable = true;
  };

  xdg.configFile."kubeconfigs/ops.yaml".source = ./kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ./kubeswitch/switch-config.yaml;

  home.packages = with pkgs; [
    stripe-cli

    # NATS CLI tools
    natscli
    nsc
  ];
}
