{
  mylib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = mylib.scanPaths ./.;

  home.packages = with pkgs; [
    # The version in pkgs-unstable is too old and can't keep up with the latest updates.
    # pkgs-unstable.claude-code
  ];
}
