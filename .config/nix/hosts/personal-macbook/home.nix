{
  myconfig = {
    core = {
      containers.basic.enable = true;
      containers.advanced.enable = true;
      cloudProviders.aws.enable = true;
      cloudProviders.gcp.enable = true;
      cloudProviders.azure.enable = true;
      cloudProviders.digitalocean.enable = true;
      devops.enable = true;
      utilities.enable = true;
      ai.enable = true;
    };

    languages = {
      bun.enable = true;
      go.enable = true;
      rust.enable = true;
      python.enable = true;
      kcl.enable = true;
    };

    databases = {
      mongodb.enable = false;
      postgresql.enable = true;
      mysql.enable = false;
      sqlite.enable = true;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "pibox.local" = {
        hostname = "pibox.local";
        user = "pibox";
        forwardAgent = false;
      };
    };
  };

  programs.zsh.initContent = ''
    export DOTNET_ROOT=$HOME/.dotnet
    export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools:/usr/local/share/dotnet
  '';
}
