{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    python3
  ];
}
