{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Kitty Configuration
#
# Useful Hot Keys for Linux(replace `ctrl + shift` with `cmd` on macOS)):
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
{
  programs.kitty = {
    enable = true;
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    themeFile = "Catppuccin-Frappe";
    font = {
      name = "MonaspiceNeNFM-Regular";
      # use different font size on macOS
      size = 12.5;
    };

    keybindings = {
      "cmd+c" =             "copy_to_clipboard";
      "cmd+v" =             "paste_from_clipboard";
      "shift+insert" =      "paste_from_clipboard";
      "alt+backspace" =     "send_text all \\x17";
      "super+backspace" =   "send_text all \\x15";
      "cmd+right" =         "send_text all \\x1b[F";
      "cmd+left" =          "send_text all \\x1b[H";
      "alt+left" =          "send_text all \\x1b\\x62";
      "alt+right" =         "send_text all \\x1b\\x66";
    };


    settings = {
      background_opacity = "0.94";
      window_margin_width = "20 2 0";
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      hide_window_decorations = "titlebar-only";
      macos_show_window_title_in = "all";
      enable_audio_bell = false;
      resize_in_steps = true;
      mouse_map = "cmd+left release grabbed,ungrabbed mouse_handle_click link";

      font_features = "MonaspiceNeNFM-Regular +liga +calt";
      bold_font = "MonaspiceNe Nerd Font Mono Bold";
      italic_font = "MonaspiceNe Nerd Font Mono Italic";
      bold_italic_font = "MonaspiceNe Nerd Font Mono Bold Italic";

      modify_font = "cell_width 95% cell_height -2px baseline 2";
    };

    # macOS specific settings
    darwinLaunchOptions = [];
  };
}
