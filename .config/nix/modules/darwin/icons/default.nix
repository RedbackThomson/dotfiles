{pkgs, ...}: {
  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "${pkgs.kitty}/Applications/kitty.app";
        icon = ./terminal.icns;
      }
      {
        path = "/Applications/Spotify.app";
        icon = ./spotify.icns;
      }
      {
        path = "/Applications/Slack.app";
        icon = ./slack.icns;
      }
      {
        path = "/Applications/Visual Studio Code.app";
        icon = ./vscode.icns;
      }
      {
        path = "/Applications/Firefox.app";
        icon = ./firefox.icns;
      }
      {
        path = "/Applications/1Password.app";
        icon = ./1password.icns;
      }
      {
        path = "/Applications/Signal.app";
        icon = ./signal.icns;
      }
      {
        path = "/Applications/Canary Mail.app";
        icon = ./canary.icns;
      }
      {
        path = "/Applications/Zoom.app";
        icon = ./zoom.icns;
      }
    ];
  };
}
