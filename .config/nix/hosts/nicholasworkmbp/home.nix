{ pkgs, ...}: {
  myconfig = {
    core = {
      containers.basic.enable = true;
      containers.advanced.enable = true;
      cloudProviders.aws.enable = true;
      cloudProviders.gcp.enable = true;
      cloudProviders.azure.enable = true;
      cloudProviders.digitalocean.enable = false;
      devops.enable = true;
      utilities.enable = true;
      ai.enable = true;
    };

    languages = {
      bun.enable = false;
      go.enable = true;
      rust.enable = false;
      python.enable = false;
      kcl.enable = true;
    };
  };


  xdg.configFile."kubeconfigs/ops.yaml".source = ./kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ./kubeswitch/switch-config.yaml;

  home.packages = with pkgs; [
    stripe-cli

    # NATS CLI tools
    natscli
    nsc
  ];

  programs.zsh.initContent = ''
    source $HOME/scripts/upbound-jump.sh
    source $HOME/scripts/upbound-kubedebug.sh
    source $HOME/scripts/kubectl-aliases.sh
  '';
}
