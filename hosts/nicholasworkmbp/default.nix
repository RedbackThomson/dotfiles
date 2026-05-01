_:
#############################################################
#
#  Work - M3 MacBook Pro 16-inch
#
#############################################################
let
  hostname = "nicholasworkmbp";
in {
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
