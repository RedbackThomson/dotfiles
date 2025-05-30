# ... existing code from home/base/core/languages/python.nix ...
{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    python3
  ];
}
