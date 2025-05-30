# ... existing code from home/base/tui/encryption/default.nix ...
{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    sops
    rclone
  ];
}
