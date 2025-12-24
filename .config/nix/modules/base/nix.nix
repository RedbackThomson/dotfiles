{
  myvars,
  ...
}: {
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = [myvars.username];

    substituters = [
      "https://nix-community.cachix.org"
    ];
  };
}
