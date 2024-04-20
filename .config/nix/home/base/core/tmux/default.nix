{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
    # programs.tmux = {
    #     enable = true;
    #     terminal = "screen-256color";
    #     shell = "${pkgs.zsh}/bin/zsh";
    #     escapeTime = 0;
    #     newSession = true;
    #     extraConfig = lib.strings.concatStringsSep "\n" [(builtins.readFile ./tmux.conf) (builtins.readFile ./tmux.conf.local)];
    #     plugins = with pkgs.vimPlugins;
    #     [
    #         # catppuccin
    #     ];
    # };
}
