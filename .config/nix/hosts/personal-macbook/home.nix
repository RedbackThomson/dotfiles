{
  myconfig.languages = {
    bun.enable = true;
    go.enable = true;
    rust.enable = true;
    python.enable = true;
    kcl.enable = true;
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

  programs.zsh.initExtra = ''
    export DOTNET_ROOT=$HOME/.dotnet
    export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools:/usr/local/share/dotnet
  '';
}
