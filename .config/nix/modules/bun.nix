# ... existing code from home/base/core/languages/bun.nix ...
{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    pkgs-unstable.bun
  ];
}
