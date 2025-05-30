# ... existing code from home/base/core/languages/kcl.nix ...
{pkgs, ...}: {
  home.packages = with pkgs; [
    kcl
  ];
}
