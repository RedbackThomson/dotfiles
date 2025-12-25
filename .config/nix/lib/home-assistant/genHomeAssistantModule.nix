{
  pkgs,
  ...
}:
let
  lib = pkgs.lib;
in
{
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant;

    extraComponents = [
      # Core integrations
      "default_config"
      "met"
      "esphome"
    ];

    config = {
      default_config = {};

      homeassistant = {
        latitude = "37.773878";
        longitude = "-122.396182";
        elevation = 0;
        unit_system = "metric";
        time_zone = "America/Los_Angeles";
        version = "2025.12.0";
      };

      http = {
        server_host = "0.0.0.0";
        server_port = 8123;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };

      tapo.discovery = true;

      automation = import ./automations.nix;
      script = import ./scripts.nix;
    };
  };
}