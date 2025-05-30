{pkgs, ...}: {
  home.packages = with pkgs; [
    neofetch # Display system settings and information
    vhs # Record, replay and export command line history
    viddy # A better version of `watch`
    earthly # CLI tool for running Earthfiles
    cloc # Count lines of code
    ncdu # Disk usage analyzer

    terraform # Terraform CLI
    doctl # DigitalOcean CLI
  ];
}
