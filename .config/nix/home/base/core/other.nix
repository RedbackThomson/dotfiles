{
  pkgs,
  attic,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    neofetch

    # Record, replay and export command line history
    vhs

    # A better version of `watch`
    viddy

    # CLI tool for running Earthfiles
    earthly

    terraform

    doctl
  ];
}
