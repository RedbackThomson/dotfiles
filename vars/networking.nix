{lib}: rec {
  mainGateway = "192.168.3.1"; # main router
  prefixLength = 24;
  nameservers = ["8.8.8.8" "8.8.4.4"];

  tailnetDomain = "tailb0b05.ts.net";
  tailnetFqdn = name: "${name}.${tailnetDomain}";

  hostsAddr = {
    # ============================================
    # Homelab-0 VMs
    # ============================================
    homelab-0-k3s-0 = {
      iface = "enp0s18";
      ipv4 = "192.168.3.151";
    };

    homelab-0-k3s-1 = {
      iface = "enp0s18";
      ipv4 = "192.168.3.155";
    };

    homelab-0-home-assistant = {
      iface = "enp0s18";
      ipv4 = "192.168.3.152";
    };

    homelab-0-ollama = {
      iface = "enp0s18";
      ipv4 = "192.168.3.153";
    };

    homelab-0-devbox = {
      iface = "enp0s18";
      ipv4 = "192.168.3.154";
    };
  };

  # Traffic from cluster pods leaves through these nodes' addresses.
  k3sNodes = ["homelab-0-k3s-0" "homelab-0-k3s-1"];
  k3sNodeAddrs = map (name: hostsAddr.${name}.ipv4) k3sNodes;

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
