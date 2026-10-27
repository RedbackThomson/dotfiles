{ config, pkgs, ...}: {
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
      git.enable = true;
      git.jujutsu.enable = true;
    };

    editors.helix.enable = true;

    languages = {
      bun.enable = false;
      go.enable = true;
      rust.enable = false;
      python.enable = false;
      kcl.enable = true;
    };

    databases = {
      mongodb.enable = false;
      postgresql.enable = true;
      mysql.enable = true;
      sqlite.enable = true;
    };
  };


  xdg.configFile."kubeconfigs/ops.yaml".source = ./kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ./kubeswitch/switch-config.yaml;
  home.file."scripts".source = ./scripts;

  # Stable path for the dev-status plugin. Zellij keys its plugin permission
  # grant on the layout's literal location string (it shell-expands but never
  # canonicalizes), so loading from this fixed path keeps the grant across
  # rebuilds even though the wasm's store path changes with every source edit.
  home.file.".local/share/zellij/plugins/zj-redback-dev-status.wasm".source =
    "${pkgs.zj-redback-dev-status}/zj-redback-dev-status.wasm";

  home.packages = with pkgs; [
    stripe-cli

    # NATS CLI tools
    natscli
    nsc

    ngrok

    (writeShellApplication {
      name = "vcluster-shell";
      runtimeInputs = [ kubectl coreutils gnugrep gnused ];
      text = builtins.readFile ./vcluster-shell.sh;
    })

    (callPackage ./dev {
      repoRoot = "${config.home.homeDirectory}/Workspace";
    })
  ];

  programs.zsh.initContent = ''
    source $HOME/scripts/upbound-jump.sh
    source $HOME/scripts/upbound-kubedebug.sh
    source $HOME/scripts/kubectl-aliases.sh
  '';
}
