{
  config,
  lib,
  pkgs,
  myvars,
  ...
}:
#############################################################
#
#  homelab-0-devbox - Remote development VM on Proxmox
#
#  Primary dev environment reached over Tailscale. Long-running
#  agent sessions live in a persistent zellij session (see home.nix).
#
#############################################################
let
  hostName = "homelab-0-devbox";

  inherit (myvars.networking) nameservers mainGateway;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";
in {
  imports = [
    ./disko.nix
  ];

  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

  # Serial console so the Proxmox console works as a Tailscale-independent
  # break-glass path. tty1 stays primary; ttyS0 is the last entry so kernel
  # oops output lands on the serial line Proxmox exposes.
  boot.kernelParams = ["console=tty1" "console=ttyS0,115200"];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    extraConfig = ''
      serial --unit=0 --speed=115200
      terminal_input serial console
      terminal_output serial console
    '';
  };

  services.qemuGuest.enable = true;

  networking = {
    inherit hostName;

    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [iface];
    networkConfig = {
      Address = [ipv4WithMask];
      Gateway = mainGateway;
      DNS = nameservers;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Firewall on for this host (base ssh.nix leaves it off fleet-wide). The
  # tailscale interface is trusted (see modules/nixos/server/tailscale.nix), so
  # dev servers are reachable over the tailnet; on the LAN only port 22 (the
  # break-glass sshd below) is open. mkForce drops the base "testing & sharing"
  # ports so they are never exposed on the LAN.
  networking.firewall.enable = lib.mkForce true;
  networking.firewall.allowedTCPPorts = lib.mkForce [22];

  # Tailscale SSH owns port 22 on the tailnet address. Bind OpenSSH to the LAN
  # address only, so it stays a break-glass path that does not collide with
  # Tailscale SSH and does not depend on the tailnet being healthy.
  services.openssh.listenAddresses = [
    {
      addr = ipv4;
      port = 22;
    }
  ];

  # Remote editor servers (VS Code, Cursor, JetBrains) ship dynamically-linked
  # binaries that need an FHS interpreter. Applied host-wide, not per-user.
  programs.nix-ld.enable = true;

  # Container runtime for ad-hoc dev stacks. No datastores are declared here;
  # they are managed directly on the host.
  virtualisation.docker.enable = true;
  users.users.${myvars.username}.extraGroups = ["docker"];

  # The Nix store on a dev host grows fast. Keep the weekly gc from the base
  # module but widen retention so in-progress work survives a collection.
  nix.gc.options = lib.mkForce "--delete-older-than 30d";

  # Work disk owned by the user; created by disko, chowned here.
  systemd.tmpfiles.rules = [
    "d /work 0755 ${myvars.username} ${myvars.username} - -"
  ];

  # Cap journald so verbose long-running sessions cannot fill the OS disk.
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=1month
  '';

  system.stateVersion = "25.05";
}
