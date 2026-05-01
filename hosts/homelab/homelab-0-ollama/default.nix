{
  config,
  pkgs,
  pkgs-unstable,
  nix-openclaw,
  myconfig,
  myvars,
  mylib,
  ...
}:
#############################################################
#
#  homelab-0-ollama - Ollama LLM server running on Homelab 0
#
#############################################################
let
  hostName = "homelab-0-ollama";

  inherit (myvars.networking) nameservers mainGateway;
  inherit (myvars.networking.hostsAddr.${hostName}) iface ipv4;
  ipv4WithMask = "${ipv4}/24";

  diskoModule = import ./disko.nix;

  signal-cli = pkgs.stdenv.mkDerivation rec {
    pname = "signal-cli";
    version = "0.14.3";
    src = pkgs.fetchurl {
      url = "https://github.com/AsamK/signal-cli/releases/download/v${version}/signal-cli-${version}.tar.gz";
      hash = "sha256-YKClExLQftDNb01QgLL/5u6Djqmfkil/KAPiSvGCbG8=";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out
      cp -r bin lib $out/
      rm -f $out/bin/signal-cli.bat
      wrapProgram $out/bin/signal-cli \
        --set JAVA_HOME "${pkgs-unstable.jdk25}" \
        --prefix PATH : "${pkgs-unstable.jdk25}/bin"
    '';
  };
in
{
  imports = [
    diskoModule
  ];

  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    inherit hostName;

    networkmanager.enable = false;
    useDHCP = false;
  };

  networking.useNetworkd = true;
  systemd.network.enable = true;

  systemd.network.networks."10-${iface}" = {
    matchConfig.Name = [ iface ];
    networkConfig = {
      Address = [ ipv4WithMask ];
      Gateway = mainGateway;
      DNS = nameservers;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8888;
        bind_address = "0.0.0.0";
        secret_key = "searxng-homelab-0-ollama";
      };
      search = {
        formats = [ "html" "json" ];
      };
    };
  };

  # services.open-webui = {
  #   enable = true;
  #   package = pkgs-unstable.open-webui;
  #   host = "0.0.0.0";
  #   port = 8080;
  #   environment = {
  #     OLLAMA_API_BASE_URL = "http://localhost:11434";
  #     ENABLE_RAG_WEB_SEARCH = "true";
  #     RAG_WEB_SEARCH_ENGINE = "searxng";
  #     SEARXNG_QUERY_URL = "http://localhost:8888/search?q=<query>";
  #   };
  # };

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.anythingllm = {
      image = "mintplexlabs/anythingllm:1.12.1";
      ports = [ "3001:3001" ];
      volumes = [
        "anythingllm-storage:/app/server/storage"
      ];
      environment = {
        STORAGE_DIR = "/app/server/storage";
        LLM_PROVIDER = "ollama";
        OLLAMA_BASE_PATH = "http://host.docker.internal:11434";
        AGENT_SEARXNG_API_URL = "http://host.docker.internal:8888";
      };
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };

  # Garnix cache for nix-openclaw prebuilt binaries
  nix.settings = {
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  services.openclaw-gateway = {
    enable = true;
    package = nix-openclaw.packages.x86_64-linux.openclaw-gateway;
    execStartPre = [
      "+${pkgs.bash}/bin/bash -c 'cp /etc/openclaw/openclaw.json /var/lib/openclaw/openclaw.json && chown openclaw:openclaw /var/lib/openclaw/openclaw.json'"
    ];
    config = {
      gateway = {
        mode = "local";
        bind = "lan";
        port = 18789;
        auth = {
          mode = "token";
        };
        controlUi = {
          enabled = true;
          allowedOrigins = [ "https://openclaw.homelab.redback.dev" ];
          dangerouslyDisableDeviceAuth = true;
        };
      };
      models = {
        providers = {
          ollama = {
            api = "ollama";
            baseUrl = "http://localhost:11434";
            models = [
              {
                id = "tinyllama";
                name = "Qwen3 0.6B";
              }
            ];
          };
        };
      };
      agents = {
        defaults = {
          model = {
            primary = "openai/gpt-4o";
            fallbacks = [ "ollama/tinyllama" ];
          };
        };
        list = [{
          id = "main";
          default = true;
          identity = {
            name = "Redback";
            theme = "just a chill dude";
            emoji = "🦘";
          };
        }];
      };
      channels = {
        signal = {
          enabled = false;
          account = "+12066298737";
          cliPath = "signal-cli";
          dmPolicy = "pairing";
        };
        discord = {
          enabled = true;
          allowFrom = [ "188029162320166913" ];
          guilds = {
            "938634098325463080" = {
              slug = "redbacks-server";
              requireMention = true;
              channels = {
                # #general
                "938634098325463082" = {enabled = true;};

                # #openclaw
                "1500189602835726517" = {
                  enabled = true;
                  requireMention = false;
                };
              };
            };
          };
        };
      };
    };
    servicePath = [ signal-cli ];
    environmentFiles = [ "/var/lib/openclaw/secrets/env" ];
    environment = {
      OLLAMA_API_KEY = "ollama-local";
      OPENCLAW_CONFIG_PATH = "/var/lib/openclaw/openclaw.json";
    };
  };

  systemd.services.openclaw-gateway = {
    restartTriggers = [ config.environment.etc."openclaw/openclaw.json".source ];
  };

  environment.systemPackages = [
    signal-cli
    nix-openclaw.packages.x86_64-linux.openclaw-gateway
  ];

  networking.firewall.allowedTCPPorts = [ 3001 11434 18789 ];
}
