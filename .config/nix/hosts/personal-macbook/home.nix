{
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
