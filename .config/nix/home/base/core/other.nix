{
  pkgs,
  attic,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    neofetch # Display system settings and information
    vhs # Record, replay and export command line history
    viddy # A better version of `watch`
    earthly # CLI tool for running Earthfiles
    cloc # Count lines of code
    
    terraform # Terraform CLI
    doctl # DigitalOcean CLI
  ];
}
