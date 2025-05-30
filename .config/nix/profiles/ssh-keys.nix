{ config, ... }:
{
  home.file.".ssh/id_ed25519".source = ../secrets/id_ed25519_work;
  home.file.".ssh/id_ed25519.pub".source = ../secrets/id_ed25519_work.pub;
} 