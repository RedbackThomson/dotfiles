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
        pkgs.ssh-to-age
      ];

      # Convert SSH host key to age format for decryption
      # This runs before agenix activation to ensure the key is available
      system.activationScripts.agenix-key = {
        text = ''
          mkdir -p /etc/age
          ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /etc/age/key
          chmod 600 /etc/age/key
        '';
        deps = [ "specialfs" ];
      };

      # Make agenix wait for the key to be generated
      system.activationScripts.agenix.deps = [ "agenix-key" ];

      # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
      age.identityPaths = [ "/etc/age/key" ];
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