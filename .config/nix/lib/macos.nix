{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [],
  darwin-custom-icons,
  myvars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  inherit (inputs) nixpkgs home-manager nix-darwin;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [darwin-custom-icons.darwinModules.default]
      ++ [
        ({lib, ...}: {
          nixpkgs.pkgs = import nixpkgs {inherit system;};
          # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
          nix.registry.nixpkgs.flake = nixpkgs;

          environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
          # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
          # discard all the default paths, and only use the one from this flake.
          nix.nixPath = lib.mkForce ["/etc/nix/inputs"];
        })
      ]
      ++ (
        lib.optionals ((lib.lists.length home-modules) > 0)
        [
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              backupFileExtension = "bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users."${myvars.username}".imports = home-modules;
            };
          }
        ]
      );
  }
