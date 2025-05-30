{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`.
  inputs,
  lib,
  mylib,
  myvars,
  darwin-custom-icons,
  system,
  genSpecialArgs,
  ...
} @ args: let
  name = "nicholasworkmbp";

  modules = {
    darwin-modules =
      (map mylib.relativeToRoot [
        # common
        "modules/darwin"
        # host specific
        "hosts/${name}"
      ])
      ++ [];
    home-modules = map mylib.relativeToRoot [
      "hosts/${name}/home.nix"
      "home/darwin"
    ];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
