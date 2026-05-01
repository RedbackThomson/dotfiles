# colmena - Remote Deployment via SSH
{
  lib,
  inputs,
  nixos-modules,
  home-modules ? [ ],
  myvars,
  system,
  tags,
  ssh-user,
  targetHost ? null,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}:
let
  inherit (inputs) home-manager;
in
{ name, ... }:
{
  deployment = {
    inherit tags;
    targetUser = ssh-user;
    # Use provided targetHost (IP address) or fall back to name (hostname)
    targetHost = if targetHost != null then targetHost else name;
    # Build on the target host instead of locally (useful when deploying from Mac to Linux)
    buildOnTarget = true;
  };

  imports =
    nixos-modules
    ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "home-manager.backup";

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users."${myvars.username}".imports = home-modules;
      }
    ]);
}