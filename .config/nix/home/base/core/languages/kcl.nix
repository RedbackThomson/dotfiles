{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    kcl-cli
  ];
}
