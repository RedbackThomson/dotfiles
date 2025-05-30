{ config, pkgs, ... }:
{
  programs.starship = {
    enable = true;
    # ...other starship settings from the old config...
  };
} 