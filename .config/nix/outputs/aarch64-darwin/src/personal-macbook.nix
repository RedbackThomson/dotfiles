{mylib, ...} @ args: let
  name = "personal-macbook";

  modules = {
    darwin-modules = map mylib.relativeToRoot [
      "modules/darwin"
      # host specific
      "profiles/personal-mac.nix"
    ];
    home-modules = [];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
