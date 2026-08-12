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
} @ args: let
  name = "homelab-0-devbox";
  tags = [name "devbox"];
  ssh-user = "root";

  inherit (myvars.networking.hostsAddr.${name}) ipv4;

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # host specific
        "secrets/nixos.nix"
        "hosts/homelab/${name}"

        "modules/nixos/server/server.nix"
        "modules/nixos/server/tailscale.nix"
      ])
      ++ [
        inputs.disko.nixosModules.disko
        {modules.secrets.devbox.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/tui.nix"
      "hosts/homelab/${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs
    // {
      inherit tags ssh-user;
      targetHost = ipv4;
    });
}
