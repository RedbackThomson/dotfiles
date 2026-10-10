{
  self,
  nixpkgs,
  pre-commit-hooks,
  darwin-custom-icons,
  colmena,
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

        # plugp100 needs ecdsa for the Tapo handshake. CVE-2024-23342 is a
        # timing side-channel in ECDSA signing, which that handshake never
        # performs - it only uses the curve parameters and point arithmetic.
        # Pinned to the exact version so a nixpkgs bump forces a fresh look.
        config.permittedInsecurePackages = [ "python3.14-ecdsa-0.19.2" ];
        overlays = [
          # The upstream flake compiles a Rust/wasm toolchain for what is a 4MB
          # plugin, and publishes no binary cache. The release artifact is
          # architecture-independent, so it serves every host. Bump url + hash
          # together on upgrade.
          (final: prev: {
            zjstatus = prev.runCommandLocal "zjstatus-0.24.0" {} ''
              install -Dm444 ${prev.fetchurl {
                url = "https://github.com/dj95/zjstatus/releases/download/v0.24.0/zjstatus.wasm";
                hash = "sha256-HM7ezh3tYs8+IJvmkM3TnKb7noIo7XGpUfZQf5lWZps=";
              }} $out/bin/zjstatus.wasm
            '';
          })

          # nixpkgs marks typish unsupported on Python 3.14 over a single failing
          # test, which takes jsons and plugp100 down with it and breaks Home
          # Assistant's Tapo support. The rest of both suites passes on 3.14, so
          # re-enable the package and skip only the tests 3.14 broke.
          (final: prev: {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (pyfinal: pyprev: {
                typish = pyprev.typish.overridePythonAttrs (old: {
                  disabled = false;
                  disabledTests = (old.disabledTests or [ ]) ++ [ "test_complex_cls_function" ];
                });
                jsons = pyprev.jsons.overridePythonAttrs (old: {
                  disabledTests = (old.disabledTests or [ ]) ++ [
                    "test_dumped_decorator_async"
                    "test_loaded_decorator_async"
                  ];
                });

                # moto, used only to test aiobotocore, cannot even be evaluated
                # on Python 3.14: it reaches aws-sam-translator through cfn-lint.
                aiobotocore = pyprev.aiobotocore.overridePythonAttrs (_: {
                  doCheck = false;
                });

                # nixpkgs ships 5.1.5, whose module layout the HACS tapo
                # component dropped in 3.4.0. Keep this in step with that
                # component's manifest requirement.
                plugp100 = pyfinal.buildPythonPackage rec {
                  pname = "plugp100";
                  version = "6.0.1";
                  pyproject = true;

                  src = prev.fetchFromGitHub {
                    owner = "petretiandrea";
                    repo = "plugp100";
                    tag = version;
                    hash = "sha256-LO0ATplDvkOmBU5PgoPjxYm6E4F1nZ1Sf0jdy1D+lzs=";
                  };

                  build-system = [ pyfinal.setuptools ];

                  dependencies = with pyfinal; [
                    aiohttp
                    certifi
                    cryptography
                    ecdsa
                    jsons
                    passlib
                    requests
                    scapy
                    semantic-version
                    urllib3
                  ];

                  nativeCheckInputs = with pyfinal; [
                    pytestCheckHook
                    pytest-asyncio
                    pyyaml
                  ];

                  # Needs credentials for real hardware in ../../.local.devices
                  disabledTestPaths = [ "tests/integration/" ];

                  pythonImportsCheck = [
                    "plugp100"
                    "plugp100.devices"
                    "plugp100.components"
                  ];
                };
              })
            ];
          })
        ];
      };
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    };

  # This is the args for all the haumea modules in this folder.
  args = {inherit inputs lib mylib myvars darwin-custom-icons genSpecialArgs;};

  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // {system = "x86_64-linux";});
  };
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

  # macOS Hosts
  darwinConfigurations =
    lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) darwinSystemValues);

  # Colmena - remote deployment via SSH
  colmena = {
    meta =
      (
        let
          system = "x86_64-linux";
        in
        {
          # colmena's default nixpkgs & specialArgs
          nixpkgs = import nixpkgs { inherit system; };
          specialArgs = genSpecialArgs system;
        }
      )
      // {
        # per-node nixpkgs & specialArgs
        nodeNixpkgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeNixpkgs or { }) nixosSystemValues
        );
        nodeSpecialArgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeSpecialArgs or { }) nixosSystemValues
        );
      };
  }
  // lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);
  # colmenaHive is the new way to configure colmena. This output proxies the
  # old colmena output to the new way.
  colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena;

  # Packages
  packages = forAllSystems (
    system:
      (allSystems.${system}.packages or {})
      # So we can run `nix run .#colmena` to deploy the cluster
      // {inherit (inputs.colmena.packages.${system}) colmena;}
      # Re-export darwin-rebuild from our pinned nix-darwin so that
      # `nix run .#darwin-rebuild -- switch --flake .` always uses the same
      # nix-darwin version as the flake (instead of the flake registry's).
      // lib.optionalAttrs (inputs.nix-darwin.packages.${system} or {} ? darwin-rebuild) {
        inherit (inputs.nix-darwin.packages.${system}) darwin-rebuild;
      }
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
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (
    # alejandra is a nix formatter with a beautiful output
    system: nixpkgs.legacyPackages.${system}.alejandra
  );
}
