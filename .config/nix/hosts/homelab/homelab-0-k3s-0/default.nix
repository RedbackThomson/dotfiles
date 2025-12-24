{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  homelab-0-k3s-0 - K3s Server VM running on Homelab 0
#
#############################################################
let
  hostName = "homelab-0-k3s-0"; # Define your hostname.

  inherit (myvars.networking) nameservers mainGateway;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";

  # k3sModule = mylib.genK3sServerModule {
  #   inherit pkgs;
  #   kubeconfigFile = "/home/${myvars.username}/.kube/config";
  #   tokenFile = config.age.secrets."k3s-token".path;
  #   # the first node in the cluster should be the one to initialize the cluster
  #   clusterInit = true;
  #   masterHost = "homelab-0-k3s-0.homelab.local";
  #   # k3sExtraArgs = [
  #   #   # IPv4 Private CIDR(full) - 172.16.0.0/12
  #   #   # IPv4 Pod     CIDR(full) - fdfd:cafe:00:0000::/64 ~ fdfd:cafe:00:7fff::/64
  #   #   # IPv4 Service CIDR(full) - fdfd:cafe:00:8000::/64 ~ fdfd:cafe:00:ffff::/64
  #   #   "--cluster-cidr=172.20.0.0/16,fdfd:cafe:00:0003::/64"
  #   #   "--service-cidr=172.21.0.0/16,fdfd:cafe:00:8003::/112"
  #   # ];
  # };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    # k3sModule
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

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";  # Update this to your actual boot disk (e.g., /dev/vda for VirtIO)
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f5be17c9-f21d-4a6a-9395-fe9142926102";
    fsType = "ext4";
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