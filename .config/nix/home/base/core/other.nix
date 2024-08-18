{
  pkgs,
  attic,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    neofetch

    vhs

    earthly

    terraform

    doctl
  ];
}
