{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.flakeReport;
  script = pkgs.writers.writePython3 "flake-report" {flakeIgnore = ["E501"];} (builtins.readFile ./flake_report.py);
in {
  options.modules.flakeReport = {
    enable = mkEnableOption "the daily flake update preview for the homelab dashboard";

    ingestTokenFile = mkOption {
      type = types.path;
      description = "File holding the dashboard's ingest token.";
    };

    githubTokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Optional GitHub token, which raises the API rate limit for the input checks.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.flake-report = {
      description = "Preview flake updates for the homelab dashboard";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      path = [config.nix.package pkgs.git];
      environment.HOME = "/var/lib/flake-report";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
        DynamicUser = true;
        StateDirectory = "flake-report";
        LoadCredential =
          ["ingest-token:${cfg.ingestTokenFile}"]
          ++ optional (cfg.githubTokenFile != null) "github-token:${cfg.githubTokenFile}";
        # Building every host takes a while; keep it from crowding out dev sessions.
        # The cap covers evaluation; builds run under nix-daemon, which the
        # script throttles to one job instead.
        MemoryHigh = "2G";
        MemoryMax = "3G";
        Nice = 19;
        IOSchedulingClass = "idle";
        CPUWeight = 20;
        TimeoutStartSec = "3h";
      };
    };

    systemd.timers.flake-report = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        RandomizedDelaySec = "15m";
        # Runs at the next boot if the host was off at 04:00.
        Persistent = true;
      };
    };
  };
}
