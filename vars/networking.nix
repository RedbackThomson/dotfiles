{lib}: rec {
  mainGateway = "192.168.1.1"; # main router
  prefixLength = 24;
  nameservers = [ "8.8.8.8" "8.8.4.4" ];

  hostsAddr = {
    # ============================================
    # Homelab-0 VMs
    # ============================================
    homelab-0-k3s-0 = {
      iface = "enp0s18";
      ipv4 = "192.168.1.151";
    };

    homelab-0-home-assistant = {
      iface = "enp0s18";
      ipv4 = "192.168.1.152";
    };
  };

  hostsInterface =
    lib.attrsets.mapAttrs (key: val: {
      interfaces."${val.iface}" = {
        useDHCP = false;
        ipv4.addresses = [
          {
            inherit prefixLength;
            address = val.ipv4;
          }
        ];
      };
    })
    hostsAddr;
}
