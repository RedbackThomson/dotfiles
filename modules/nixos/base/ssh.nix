{
  lib,
  pkgs,
  ...
}:
{
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkDefault false;
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      # root user is used for remote deployment, so we need to allow it
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # Ghostty is the only terminal used to SSH in. enableAllTerminfo would also
  # pull in terminals that must be compiled from source just for their terminfo.
  environment.systemPackages = [pkgs.ghostty.terminfo];
}
