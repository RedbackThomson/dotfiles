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

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
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

  # Cap journald so verbose long-running sessions cannot fill the disk.
  services.journald.settings.Journal = {
    SystemMaxUse = "2G";
    MaxRetentionSec = "1month";
  };

  modules.monitoring.units = [
    "docker.service"
    "prometheus-blackbox-exporter.service"
  ];

  # Probes tailnet URLs for the homelab dashboard; it runs here because pods in
  # the cluster have no route onto the tailnet.
  services.prometheus.exporters.blackbox = {
    enable = true;
    port = 9115;
    configFile = pkgs.writeText "blackbox.yml" (builtins.toJSON {
      modules = {
        http_2xx = {
          prober = "http";
          timeout = "10s";
          http.preferred_ip_protocol = "ip4";
        };
        # For endpoints that answer unauthenticated probes with 401/403, which
        # still proves the endpoint is up.
        http_reachable = {
          prober = "http";
          timeout = "10s";
          http = {
            preferred_ip_protocol = "ip4";
            valid_status_codes = [200 401 403];
          };
        };
      };
    });
  };

  # The metrics store runs on the k3s nodes and scrapes over the LAN, which is
  # otherwise closed on this host.
  networking.firewall.extraCommands = lib.concatMapStringsSep "\n" (addr: ''
    iptables -A nixos-fw -p tcp -s ${addr} -m multiport --dports 9100,9115 -j nixos-fw-accept
  '') myvars.networking.k3sNodeAddrs;

  system.stateVersion = "25.05";
}
