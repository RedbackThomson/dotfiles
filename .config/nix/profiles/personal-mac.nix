{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Editors
    ../modules/neovim.nix
    ../modules/editors.nix

    # Shell & Prompt
    ../modules/zsh.nix
    ../modules/starship.nix

    # Development Tools
    ../modules/dev-tools.nix
    ../modules/go.nix
    ../modules/bun.nix
    ../modules/python.nix
    ../modules/kcl.nix
    ../modules/container.nix
    ../modules/cloud.nix
    ../modules/kitty.nix
    ../modules/zellij.nix
    ../modules/k9s.nix

    # Security & Encryption
    ../modules/encryption.nix
    ../modules/1password.nix
    ../modules/ssh.nix

    # System Utilities
    ../modules/btop.nix
    ../modules/other.nix
    ../modules/git.nix
    ../modules/base.nix
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
