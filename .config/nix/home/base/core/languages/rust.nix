{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: {
  home.packages = with pkgs-unstable; [
    rustup
  ];

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "$CARGO_HOME/bin"
  ];
}
