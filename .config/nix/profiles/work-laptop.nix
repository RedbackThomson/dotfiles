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

  xdg.configFile."kubeconfigs/ops.yaml".source = ../hosts/nicholasworkmbp/kubeswitch/ops.yaml;
  home.file.".kube/switch-config.yaml".source = ../hosts/nicholasworkmbp/kubeswitch/switch-config.yaml;

  networking.hostName = "nicholasworkmbp";
  networking.computerName = "nicholasworkmbp";
  system.defaults.smb.NetBIOSName = "nicholasworkmbp";
} 