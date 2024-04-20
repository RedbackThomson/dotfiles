{
  self,
  nixpkgs,
  pre-commit-hooks,
  zjstatus,
  ...
} @ inputs: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  myvars = import ../vars {inherit lib;};

  # Add my custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager/darwin modules.
  genSpecialArgs = system:
    inputs
    // {
      inherit mylib myvars;

      pkgs = import inputs.nixpkgs {
        inherit system;
        # To use 1Password, we need to allow the installation of non-free software
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            zjstatus = zjstatus.packages.${prev.system}.default;
          })
        ];
      };
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    };

  # This is the args for all the haumea modules in this folder.
  args = {inherit inputs lib mylib myvars genSpecialArgs;};

  nixosSystems = {};
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // {system = "aarch64-darwin";});
  };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in {
  # Add attribute sets into outputs, for debugging
  debugAttrs = {inherit nixosSystems darwinSystems allSystems allSystemNames;};

  # NixOS Hosts
  nixosConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or {}) nixosSystemValues);

  # Colmena - remote deployment via SSH
  colmena =
    {
      meta =
        (
          let
            system = "x86_64-linux";
          in {
            # colmena's default nixpkgs & specialArgs
            nixpkgs = import nixpkgs {inherit system;};
            specialArgs = genSpecialArgs system;
          }
        )
        // {
          # per-node nixpkgs & specialArgs
          nodeNixpkgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeNixpkgs or {}) nixosSystemValues);
          nodeSpecialArgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or {}) nixosSystemValues);
        };
    }
    // lib.attrsets.mergeAttrsList (map (it: it.colmena or {}) nixosSystemValues);

  # macOS Hosts
  darwinConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);

  # Packages
  packages = forAllSystems (
    system: allSystems.${system}.packages or {}
  );

  checks = forAllSystems (
    system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = mylib.relativeToRoot ".";
        hooks = {
          alejandra.enable = true; # formatter
          typos.enable = true; # Source code spell checker
          prettier.enable = true;
          # deadnix.enable = true; # detect unused variable bindings in `*.nix`
          # statix.enable = true; # lints and suggestions for Nix code(auto suggestions)
        };
        settings = {
          typos = {
            write = true; # Automatically fix typos
            configPath = "./.typos.toml"; # relative to the flake root
          };
          prettier = {
            write = true; # Automatically format files
            configPath = "./.prettierrc.yaml"; # relative to the flake root
          };
        };
      };
    }
  );

  # Development Shells
  devShells = forAllSystems (
    system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # fix https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          bashInteractive
          # fix `cc` replaced by clang, which causes nvim-treesitter compilation error
          gcc
          # Nix-related
          alejandra
          deadnix
          statix
          # spell checker
          typos
          # code formatter
          nodePackages.prettier
        ];
        name = "dots";
        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (
    # alejandra is a nix formatter with a beautiful output
    system: nixpkgs.legacyPackages.${system}.alejandra
  );
}
