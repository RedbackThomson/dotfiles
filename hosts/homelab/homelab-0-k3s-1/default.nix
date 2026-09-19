{
  config,
  pkgs,
  myconfig,
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  homelab-0-k3s-1 - K3s Agent VM running on Homelab 0
#
#############################################################
let
  hostName = "homelab-0-k3s-1"; # Define your hostname.

  inherit (myvars.networking) nameservers mainGateway;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";

  k3sModule = mylib.genK3sNodeModule {
    inherit pkgs hostName;
    tokenFile = config.age.secrets."k3s-token".path;
    # An agent carries workloads so a server restart does not take every pod
    # with it; etcd stays a single member.
    role = "agent";
    # The server's own name does not resolve, but its address is a cert SAN.
    masterHost = myvars.networking.hostsAddr.homelab-0-k3s-0.ipv4;
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    k3sModule
  ];

  # supported file systems, so we can mount any removable disks with these filesystems
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    #"zfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  # Ensure necessary drivers are loaded in initrd for disk detection
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    inherit hostName;

    # we use networkd instead
    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [ iface ];
    networkConfig = {
      Address = [ ipv4WithMask ];
      Gateway = mainGateway;
      DNS = nameservers;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
