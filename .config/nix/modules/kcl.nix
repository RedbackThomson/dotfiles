# ... existing code from home/base/core/languages/kcl.nix ...
{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    kcl
  ];
}
