{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "homelab-0-k3s-0";
  tags = [ name ];
  ssh-user = "root";

  inherit (myvars.networking.hostsAddr.${name}) ipv4;

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # host specific
        "secrets/nixos.nix"
        "hosts/homelab/${name}"

        "modules/nixos/server/server.nix"
      ])
      ++ [
        inputs.disko.nixosModules.disko
        { modules.secrets.server.kubernetes.enable = true; }
      ];
    home-modules = map mylib.relativeToRoot [
      "hosts/homelab/common/home.nix"
      
      "home/linux/tui.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // {
    inherit tags ssh-user;
    targetHost = ipv4;
  });
}