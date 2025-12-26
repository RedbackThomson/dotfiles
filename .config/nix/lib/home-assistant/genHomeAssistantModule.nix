{
  pkgs,
  externalUrl ? "https://hass.homelab.redback.dev",
  internalUrl ? "http://127.0.0.1:8123",
  ...
}:
let
  lib = pkgs.lib;
in
{
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;

    # --- Home Assistant YAML -> Nix config ---
    config = {
      default_config = {};

      homeassistant = {
        latitude = 37.773930;
        longitude = -122.396241;
        elevation = 0;
        unit_system = "metric";
        time_zone = "America/Los_Angeles";
        currency = "USD";
        country = "US";
        external_url = externalUrl;
        internal_url = internalUrl;
      };

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "172.19.0.0/24"
          "127.0.0.1"
          "::1"
          "fe80::/64"
          "fe00::/64"
          "fd00::/64"

          # Homelab-0-k3s-0 VMs
          "192.168.1.151"
        ];
      };

      frontend.themes = "!include_dir_merge_named themes";

      tts = [{ platform = "google_translate"; }];

      automation = "!include automations.yaml";
      script     = "!include scripts.yaml";
      scene      = "!include scenes.yaml";

      tapo.discovery = true;

      template = [
        {
          cover = [
            {
              name = "Bedroom Curtain";
              unique_id = "bedroom_curtain";
              device_class = "curtain";

              # Must be open/opening/closed/closing/true/false/none.
              state = ''
                {% set s = states('cover.bedroom_curtains_curtain') %}
                {% if s == 'open' %} open
                {% elif s == 'closed' %} closed
                {% elif s == 'opening' %} opening
                {% elif s == 'closing' %} closing
                {% else %} none
                {% endif %}
              '';

              position = ''
                {% set pos = state_attr('cover.bedroom_curtains_curtain', 'current_position') | int(0) %}
                {{ 100 - pos }}
              '';

              open_cover = {
                service = "cover.close_cover";
                target.entity_id = "cover.bedroom_curtains_curtain";
              };
              close_cover = {
                service = "cover.open_cover";
                target.entity_id = "cover.bedroom_curtains_curtain";
              };
              stop_cover = {
                service = "cover.stop_cover";
                target.entity_id = "cover.bedroom_curtains_curtain";
              };
              set_cover_position = {
                service = "cover.set_cover_position";
                data_template = {
                  entity_id = "cover.bedroom_curtains_curtain";
                  position = ''{{ 100 - position }}'';
                };
              };
            }
          ];
        }
      ];
    };

    # --- Core components HACS depends on ---
    extraComponents = [
      "default_config"
      "http"
      "frontend"
      "lovelace"
      "websocket_api"
      "repairs"

      # Integrations you have config entries for (from your errors)
      "zha"
      "sonos"
      "cast"
      "apple_tv"
      "homekit"
      "esphome"
      "tplink"
      "tuya"
      "nest"
      "thread"
      "dlna_dmr"
      "samsungtv"

      # YAML-declared
      "tts"
      "google_translate"
      "template"
      "automation"
      "script"
      "scene"
    ];

    # --- Python deps by integration / purpose ---
    extraPackages = py: with py; [
      # HACS (custom component)
      aiogithubapi

      # google_translate TTS
      gtts

      # Sonos
      soco

      # Thread / OTBR
      python-otbr-api

      # HomeKit
      hap-python

      # Google Cast
      pychromecast

      # Apple TV
      pyatv

      # Tuya (core "tuya" integration)
      tuya-iot-py-sdk

      # Nest (core "nest" integration)
      google-nest-sdm

      # TP-Link / Kasa (core "tplink" integration)
      python-kasa

      # ESPHome
      aioesphomeapi

      # Samsung TV (MAC lookup helper used by some flows)
      getmac

      # Tapo (your custom component "tapo")
      plugp100

      # Amazon S3
      aiobotocore
      aioboto3

      # Optional perf: aiohttp_fast_zlib warning
      zlib-ng
      isal
    ];
  };
}