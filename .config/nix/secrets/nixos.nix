{
  lib,
  config,
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}:
with lib;
let
  cfg = config.modules.secrets;

  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = myvars.username;
  };
in
{
  imports = [
    agenix.nixosModules.default
  ];

  options.modules.secrets = {
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
  };

  config = (mkMerge [
    {
      environment.systemPackages = [
        agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];

      # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
      age.identityPaths = [ "/etc/ssh/agenix" ];
    }

    (mkIf cfg.server.kubernetes.enable {
      age.secrets = {
        "k3s-token" = {
          file = "${mysecrets}/secrets/k3s/token.age";
        }
        // high_security;
      };
    })
  ]);
}