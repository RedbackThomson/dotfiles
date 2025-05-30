{ config, pkgs, ... }:
{
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/starship.nix
    # Add other shared modules as needed
    ./ssh-keys.nix
  ];

  # Host-specific settings
  home.username = "nicholasthomson";
  home.homeDirectory = "/Users/nicholasthomson";

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

  networking.hostName = "personal-macbook";
  networking.computerName = "personal-macbook";
  system.defaults.smb.NetBIOSName = "personal-macbook";
} 