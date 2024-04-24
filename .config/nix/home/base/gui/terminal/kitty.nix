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
    theme = "Catppuccin-Frappe";
    font = {
      name = "JetBrainsMono Nerd Font";
      # use different font size on macOS
      size = 13;
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
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      enable_audio_bell = false;
      resize_in_steps = true;
      mouse_map = "cmd+left release grabbed,ungrabbed mouse_handle_click link";
    };

    # macOS specific settings
    darwinLaunchOptions = [];
  };
}
