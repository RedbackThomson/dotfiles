{
  pkgs,
  ...
}: {
  # https://github.com/catppuccin/btop/blob/main/themes/catppuccin_mocha.theme
  xdg.configFile."btop/themes".source = "${
    pkgs.catppuccin.override {
      themeList = ["btop"];
      variant = "frappe";
    }
  }/btop";

  # replacement of htop/nmon
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_frappe";
      theme_background = false; # make btop transparent
    };
  };
}
