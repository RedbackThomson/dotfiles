_:
#############################################################
#
#  Personal - M1 MacBook Pro 13-inch
#
#############################################################
let
  hostname = "personal-macbook";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
