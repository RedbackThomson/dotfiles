{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.monitoring;
  textfileDir = "/var/lib/prometheus-node-exporter-text";

  nixosMetrics = pkgs.writeShellScript "nixos-textfile-metrics" ''
    set -eu
    # /run/current-system is only repointed at the end of activation, so take the
    # new system from the caller. /run/booted-system does not exist during boot.
    current=$(readlink -f "$1")
    booted=$(readlink -f /run/booted-system 2>/dev/null || echo "$current")
    generation=$(readlink /nix/var/nix/profiles/system | ${pkgs.gnused}/bin/sed -n 's/^system-\([0-9]*\)-link$/\1/p')

    reboot=0
    for part in kernel initrd kernel-modules systemd; do
      if [ "$(readlink -f "$booted/$part")" != "$(readlink -f "$current/$part")" ]; then
        reboot=1
      fi
    done

    mkdir -p ${textfileDir}
    tmp=$(mktemp ${textfileDir}/.nixos.prom.XXXXXX)
    cat > "$tmp" <<EOF
    # HELP nixos_system_info The running NixOS system and the flake revision it was built from.
    # TYPE nixos_system_info gauge
    nixos_system_info{revision="${toString config.system.configurationRevision}",version="${config.system.nixos.version}",toplevel="$current"} 1
    # HELP nixos_generation The system profile generation that is currently active.
    # TYPE nixos_generation gauge
    nixos_generation ''${generation:-0}
    # HELP nixos_reboot_required Whether the kernel, initrd or systemd differ from the booted system.
    # TYPE nixos_reboot_required gauge
    nixos_reboot_required $reboot
    # HELP nixos_activation_timestamp_seconds When the system was last activated.
    # TYPE nixos_activation_timestamp_seconds gauge
    nixos_activation_timestamp_seconds $(date +%s)
    EOF
    chmod 644 "$tmp"
    mv "$tmp" ${textfileDir}/nixos.prom
  '';
in {
  options.modules.monitoring.units = mkOption {
    type = types.listOf types.str;
    default = [];
    example = ["k3s.service"];
    description = ''
      systemd units the node exporter reports on. Each host lists the services it
      exists to run; reporting every unit would multiply the series stored per host.
    '';
  };

  config = {
    modules.monitoring.units = [
      "sshd.service"
      "tailscaled.service"
      "prometheus-node-exporter.service"
    ];

    # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/monitoring/prometheus/exporters/node.nix
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9100;
      # There're already a lot of collectors enabled by default
      # https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default
      enabledCollectors = [
        "systemd"
        "logind"
        "textfile"
      ];

      extraFlags = [
        "--collector.textfile.directory=${textfileDir}"
        "--collector.systemd.unit-include=^(${concatStringsSep "|" (unique cfg.units)})$"
        # Exclude pseudo/ephemeral FS:
        #   - /proc, /sys: kernel pseudo-FS, always size 0
        #   - /dev: tmpfs/devices, not meaningful for disk usage
        # Exclude system/runtime tmp dirs:
        #   - /run/credentials/... → systemd service secrets (strict perms)
        #   - /run/user/... → per-user tmpfs (0700, IPC sockets, not storage)
        # Exclude container/runtime mounts:
        #   - /var/lib/docker/, /var/lib/containers/ and /var/lib/kubelet/ → too much overlay/tmpfs mounts,
        #     often EACCES (strict perms, namespaces) → false alerts
        # Exclude mounts inside user homes:
        #   - /home/<user>/... → per-user mounts, not host storage. /home itself is still
        #     reported if it is its own filesystem.
        # Note: ^(/|/persistent/) prefix ensures both root-level and
        #       /persistent-prefixed paths (used in NixOS's tmpfs-as-root setup) are excluded.
        "--collector.filesystem.mount-points-exclude=^(/|/persistent/)(dev|proc|sys|run/credentials/.+|run/user/.+|var/lib/docker/.+|var/lib/containers/.+|var/lib/kubelet/.+|home/[^/]+)($|/)"
      ];
    };

    # Activation runs on every switch and on every boot, which are exactly the
    # moments the generation, revision or reboot state can change.
    system.activationScripts.nixosTextfileMetrics.text = ''${nixosMetrics} "$systemConfig"'';
  };
}
