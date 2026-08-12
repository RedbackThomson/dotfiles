{disko, ...}: {
  disko.devices = {
    disk = {
      # OS disk: ESP + Nix store + root. Destroyed and recreated on a
      # from-scratch rebuild; must hold nothing the user cares about.
      os = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      # Work disk: user work trees and service state. Kept off the OS disk so
      # an OS rebuild or rollback cannot touch it.
      work = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            work = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/work";
              };
            };
          };
        };
      };
    };
  };
}
