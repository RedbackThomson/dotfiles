{
  config,
  pkgs,
  ...
}: let
  # Created by hand (root-only) on each Mac; without it activation skips the report.
  tokenFile = "/etc/homelab-dashboard/ingest-token";
in {
  # Laptops cannot be scraped, so each activation tells the homelab dashboard
  # which revision it is now running. A Mac off the tailnet just misses one report.
  system.activationScripts.postActivation.text = ''
    if [ -r ${tokenFile} ]; then
      generation=$(readlink /nix/var/nix/profiles/system | sed -n 's/^system-\([0-9]*\)-link$/\1/p')
      ${pkgs.curl}/bin/curl -sf -m 5 -o /dev/null \
        -H @<(printf 'Authorization: Bearer %s' "$(cat ${tokenFile})") \
        -H 'Content-Type: application/json' \
        -d "{\"host\":\"${config.networking.hostName}\",\"revision\":\"${toString config.system.configurationRevision}\",\"generation\":''${generation:-0}}" \
        https://dashboard.tailb0b05.ts.net/api/reports/darwin \
        || echo "homelab dashboard: could not report this activation" >&2
    fi
  '';
}
