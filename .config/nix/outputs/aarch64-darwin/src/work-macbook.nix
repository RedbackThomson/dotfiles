{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
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
        "modules/darwin"
        # host specific
        "profiles/work-laptop.nix"
      ])
      ++ [];
    home-modules = [];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
