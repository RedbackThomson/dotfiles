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
#  homelab-0-home-assistant - Home Assistant VM running on Homelab 0
#
#############################################################
let
  hostName = "homelab-0-home-assistant"; # Define your hostname.

  inherit (myvars.networking) nameservers mainGateway;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";

  homeAssistantModule = mylib.genHomeAssistantModule {
    inherit pkgs;
    externalUrl = "https://hass.homelab.redback.dev";
    internalUrl = "http://${ipv4}:8123";
  };

  diskoModule = import ./disko.nix;
in
{
  imports = [
    homeAssistantModule
    diskoModule
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