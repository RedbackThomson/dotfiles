{
  lib,
  pkgs,
  config,
  ...
}:
###########################################################
#
# Ghostty Configuration
#
# Install via Homebrew: `brew install --cask ghostty`
#
# Useful Hot Keys (replace `ctrl + shift` with `cmd` on macOS):
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
let
  iconPath = "${config.xdg.configHome}/ghostty/ghostty.icns";
in
{
  xdg.configFile."ghostty/ghostty.icns".source = ./ghostty.icns;

  xdg.configFile."ghostty/config".text = ''
    theme = Catppuccin Frappe

    font-family = MonaspiceNe Nerd Font Mono
    font-size = 14
    font-feature = liga
    font-feature = calt

    background-opacity = 0.94
    window-padding-x = 5
    # window-padding-y = 5
    window-decoration = auto

    # macOS specific settings
    macos-titlebar-style = transparent
    macos-option-as-alt = true
    macos-icon = custom
    macos-custom-icon = ${iconPath}

    # Mouse behavior
    mouse-hide-while-typing = true

    # keybind = cmd+c=copy_to_clipboard
    # keybind = cmd+v=paste_from_clipboard
    # keybind = shift+insert=paste_from_clipboard
    # keybind = alt+backspace=text:\x17
    # keybind = super+backspace=text:\x15
    # keybind = cmd+right=text:\x1b[F
    # keybind = cmd+left=text:\x1b[H
    # keybind = alt+left=text:\x1bb
    # keybind = alt+right=text:\x1bf
  '';
}
