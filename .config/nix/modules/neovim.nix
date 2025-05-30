{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    # ...other neovim settings from the old config...
  };
} 