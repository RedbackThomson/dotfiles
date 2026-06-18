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
    # We track nix-darwin master (26.11) for the Homebrew 6.0 tap-trust
    # fix while pinning Nixpkgs to 25.11 via `nixpkgs.pkgs` below, so the
    # release-match assertion must be disabled.
    enableNixpkgsReleaseCheck = false;
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
            home-manager.backupFileExtension = "bak";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users."${myvars.username}".imports = home-modules;
          }
        ]
      ) ++ [
        inputs.determinate.darwinModules.default
        ({...}: {
          nix.settings = {
            experimental-features = "nix-command flakes";

            determinate-nix.customSettings = {
              extra-substituters = [
                "https://cache.flox.dev"
                "https://colmena.cachix.org"
              ];
              extra-trusted-public-keys = [
                "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
                colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=
              ];
            };
          };
        })
      ];
  }
