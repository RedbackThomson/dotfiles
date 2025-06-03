{
  pkgs,
  pkgs-unstable,
  ...
}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
#
# NOTE: Some options are not supported by nix-darwin directly, manually set them:
#   1. To avoid conflicts with neovim, disable ctrl + up/down/left/right to switch spaces in:
#     [System Preferences] -> [Keyboard] -> [Keyboard Shortcuts] -> [Mission Control]
#   2. Disable use Caps Lock as 中/英 switch in:
#     [System Preferences] -> [Keyboard] -> [Input Sources] -> [Edit] -> [Use 中/英 key to switch ] -> [Disble]
###################################################################################
{
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;

  system = {
    defaults = {
      NSGlobalDomain = {
        "NSWindowShouldDragOnGesture" = true; # allow dragging windows with ctrl + cmd
        "NSAutomaticWindowAnimationsEnabled" = false; # disable window animations
        "_HIHideMenuBar" = true; # Hide the top menu bar
      };

      spaces = {
        "spans-displays" = true; # Displays have separate Spaces
      };
    };
  };

  # system = {
  #   # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
  #   activationScripts.postUserActivation.text = ''
  #     # activateSettings -u will reload the settings from the database and apply them to the current session,
  #     # so we do not need to logout and login again to make the changes take effect.
  #     /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  #   '';

  #   defaults = {
  #     # customize dock
  #     dock = {
  #       autohide = false;
  #       show-recents = false; # do not show recent apps in dock
  #       # do not automatically rearrange spaces based on most recent use.
  #       mru-spaces = false;
  #     };

  #     # customize finder
  #     finder = {
  #       _FXShowPosixPathInTitle = true; # show full path in finder title
  #       AppleShowAllExtensions = true; # show all file extensions
  #       FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
  #       QuitMenuItem = true; # enable quit menu item
  #       ShowPathbar = true; # show path bar
  #       ShowStatusBar = true; # show status bar
  #     };

  #     # customize trackpad
  #     trackpad = {
  #       Clicking = true;
  #       TrackpadRightClick = true; # enable two finger right click
  #     };

  #     # customize macOS
  #     NSGlobalDomain = {
  #       # `defaults read NSGlobalDomain "xxx"`
  #       "com.apple.swipescrolldirection" = false; # enable natural scrolling(default to true)
  #       "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key

  #       # Appearance
  #       AppleInterfaceStyle = "Dark"; # dark mode

  #       AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
  #       ApplePressAndHoldEnabled = true; # enable press and hold

  #       # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
  #       # This is very useful for vim users, they use `hjkl` to move cursor.
  #       # sets how long it takes before it starts repeating.
  #       InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
  #       # sets how fast it repeats once it starts.
  #       KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

  #       NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
  #       NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
  #       NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
  #       NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
  #       NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
  #       NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
  #       NSNavPanelExpandedStateForSaveMode2 = true;
  #     };

  #     # customize settings that not supported by nix-darwin directly
  #     # Incomplete list of macOS `defaults` commands :
  #     #   https://github.com/yannbertrand/macos-defaults
  #     CustomUserPreferences = {
  #       ".GlobalPreferences" = {
  #         # automatically switch to a new space when switching to the application
  #         AppleSpacesSwitchOnActivate = true;
  #       };
  #       NSGlobalDomain = {
  #         # Add a context menu item for showing the Web Inspector in web views
  #         WebKitDeveloperExtras = true;
  #       };
  #       "com.apple.finder" = {
  #         AppleShowAllFiles = true;
  #         ShowExternalHardDrivesOnDesktop = true;
  #         ShowHardDrivesOnDesktop = true;
  #         ShowMountedServersOnDesktop = true;
  #         ShowRemovableMediaOnDesktop = true;
  #         _FXSortFoldersFirst = true;
  #         # When performing a search, search the current folder by default
  #         FXDefaultSearchScope = "SCcf";
  #       };
  #       "com.apple.desktopservices" = {
  #         # Avoid creating .DS_Store files on network or USB volumes
  #         DSDontWriteNetworkStores = true;
  #         DSDontWriteUSBStores = true;
  #       };
  #       "com.apple.spaces" = {
  #         "spans-displays" = 0; # Display have seperate spaces
  #       };
  #       "com.apple.WindowManager" = {
  #         EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
  #         StandardHideDesktopIcons = 0; # Show items on desktop
  #         HideDesktop = 0; # Do not hide items on desktop & stage manager
  #         StageManagerHideWidgets = 0;
  #         StandardHideWidgets = 0;
  #       };
  #       "com.apple.screencapture" = {
  #         location = "~/Downloads";
  #         type = "png";
  #       };
  #       "com.apple.AdLib" = {
  #         allowApplePersonalizedAdvertising = false;
  #       };
  #       # Prevent Photos from opening automatically when devices are plugged in
  #       "com.apple.ImageCapture".disableHotPlug = true;
  #     };

  #     loginwindow = {
  #       GuestEnabled = false; # disable guest user
  #       SHOWFULLNAME = true; # show full name in login window
  #     };
  #   };

  #   # keyboard settings is not very useful on macOS
  #   # the most important thing is to remap option key to alt key globally,
  #   # but it's not supported by macOS yet.
  #   keyboard = {
  #     enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

  #     # NOTE: do NOT support remap capslock to both control and escape at the same time
  #     remapCapsLockToControl = false; # remap caps lock to control, useful for emac users
  #     remapCapsLockToEscape = true; # remap caps lock to escape, useful for vim users

  #     # swap left command and left alt
  #     # so it matches common keyboard layout: `ctrl | command | alt`
  #     #
  #     # disabled, caused only problems!
  #     swapLeftCommandAndLeftAlt = false;
  #   };
  # };

  # Set your time zone.
  # comment this due to the issue:
  #   https://github.com/LnL7/nix-darwin/issues/359
  # time.timeZone = "Asia/shanghai";

  # Fonts
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      source-sans
      source-serif

      pkgs-unstable.nerd-fonts.symbols-only
      pkgs-unstable.nerd-fonts.fira-code
      pkgs-unstable.nerd-fonts.jetbrains-mono
      pkgs-unstable.nerd-fonts.iosevka
      pkgs-unstable.nerd-fonts.monaspace
    ];
  };
}
