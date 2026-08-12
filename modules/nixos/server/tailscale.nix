{
  config,
  myvars,
  ...
}:
#############################################################
#
#  Tailscale with unattended auth for a tagged node.
#
#  Opt-in: import this module and set modules.secrets.devbox.enable so the
#  authkey secret is present. The authkey is decrypted by agenix before
#  tailscaled starts (agenix activation runs pre-network), so the node joins
#  the tailnet on a cold boot with no interactive login.
#
#############################################################
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;

    # tag:devbox lets tailnet ACLs target this host by role, not by name.
    # --ssh makes tailscaled own port 22 on the tailnet address.
    extraUpFlags = [
      "--ssh"
      "--advertise-tags=tag:devbox"
    ];

    # Open UDP 41641 for direct (non-relayed) connections.
    openFirewall = true;

    # Let the primary user run `tailscale cert` / `tailscale serve` for TLS
    # under the host's MagicDNS name without root.
    permitCertUid = myvars.username;
  };

  # Everything on the tailnet interface is reachable; the LAN and default zone
  # are not (see the host's firewall settings).
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
