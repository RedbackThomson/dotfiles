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

    dashboardUrl = mkOption {
      type = types.str;
      default = "https://dashboard.tailb0b05.ts.net";
      description = "The homelab dashboard the report is posted to.";
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
      environment = {
        HOME = "/var/lib/flake-report";
        DASHBOARD_URL = cfg.dashboardUrl;
      };
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

    # The dashboard's "Run now" button only records a request; devbox asks for
    # pending requests rather than the cluster reaching in to start the job.
    systemd.services.flake-report-trigger = {
      description = "Start the flake report when the homelab dashboard asks for one";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = ["ingest-token:${cfg.ingestTokenFile}"];
      };
      script = ''
        if systemctl is-active --quiet flake-report.service; then
          exit 0
        fi
        token=$(cat "$CREDENTIALS_DIRECTORY/ingest-token")
        if ${pkgs.curl}/bin/curl -sf -m 10 -H @<(printf 'Authorization: Bearer %s' "$token") \
            ${cfg.dashboardUrl}/api/flake/pending | ${pkgs.gnugrep}/bin/grep -q '"pending":true'; then
          echo "Run requested from the dashboard"
          systemctl start --no-block flake-report.service
        fi
      '';
    };

    systemd.timers.flake-report-trigger = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "minutely";
        AccuracySec = "10s";
      };
    };
  };
}
