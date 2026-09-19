{
  config,
  lib,
  myvars,
  ...
}:
with lib; let
  cfg = config.modules.tailscale;
in {
  options.modules.tailscale = {
    enable = mkEnableOption "Tailscale with unattended auth for a tagged node";

    authKeySecret = mkOption {
      type = types.str;
      default = "tailscale-authkey";
      description = ''
        Name of the agenix secret holding the tailnet auth key. Named rather
        than a path so each host can point it at its own encrypted file.
      '';
    };

    tags = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["tag:devbox"];
      description = "Tags advertised at join, so ACLs target the host by role rather than by name.";
    };

    ssh = mkOption {
      type = types.bool;
      default = false;
      description = "Whether tailscaled owns port 22 on the tailnet address.";
    };

    permitCertUid = mkOption {
      type = types.nullOr types.nonEmptyStr;
      default = myvars.username;
      description = "User allowed to run `tailscale cert` and `tailscale serve` without root.";
    };

    trustInterface = mkOption {
      type = types.bool;
      default = true;
      description = "Whether the firewall treats tailscale0 as trusted.";
    };

    servePort = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 8123;
      description = "Local port published over HTTPS on the node's MagicDNS name.";
    };

    extraUpFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional flags for `tailscale up`.";
    };
  };

  config = mkIf cfg.enable {
    # The authkey is decrypted by agenix before tailscaled starts, so the node
    # joins on a cold boot with no interactive login.
    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.${cfg.authKeySecret}.path;

      extraUpFlags =
        (optional cfg.ssh "--ssh")
        ++ (optional (cfg.tags != []) "--advertise-tags=${concatStringsSep "," cfg.tags}")
        ++ cfg.extraUpFlags;

      # UDP 41641 lets peers connect directly instead of through a DERP relay.
      openFirewall = true;

      inherit (cfg) permitCertUid;
    };

    # Everything on the tailnet interface is reachable; the LAN and default zone
    # are not (see the host's firewall settings).
    networking.firewall.trustedInterfaces = mkIf cfg.trustInterface ["tailscale0"];

    # Serve has no declarative option; the CLI writes it into tailscaled's own
    # state, so re-run it on activation to converge after a state reset.
    systemd.services.tailscale-serve = mkIf (cfg.servePort != null) {
      description = "Publish a local port on the tailnet over HTTPS";
      after = ["tailscaled.service" "tailscaled-autoconnect.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 10;
      };
      # --yes because enabling the HTTPS capability otherwise prompts, and there
      # is no terminal under systemd.
      script = "${getExe config.services.tailscale.package} serve --bg --yes ${toString cfg.servePort}";
    };
  };
}
