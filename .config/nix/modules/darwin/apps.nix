{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  #  NOTE：To remove the uninstalled APPs icon from Launchpad:
  #    1. `sudo nix store gc --debug` & `sudo nix-collect-garbage --delete-old`
  #    2. click on the uninstalled APP's icon in Launchpad, it will show a question mark
  #    3. if the app starts normally:
  #        1. right click on the running app's icon in Dock, select "Options" -> "Show in Finder" and delete it
  #    4. hold down the Option key, a `x` button will appear on the icon, click it to remove the icon
  #
  #
  ##########################################################################
  {
    # Install packages from nix's official package repository.
    #
    # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
    # But on macOS, it's less stable than homebrew.
    #
    # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
    environment.systemPackages = with pkgs; [
      neovim
      git
      gnugrep # replacee macos's grep
      gnutar # replacee macos's tar
      code-cursor
    ];
    environment.variables = {
      # Fix https://github.com/LnL7/nix-darwin/wiki/Terminfo-issues
      TERMINFO_DIRS = map (path: path + "/share/terminfo") config.environment.profiles ++ ["/usr/share/terminfo"];

      EDITOR = "nvim";
    };

    # Create /etc/zshrc that loads the nix-darwin environment.
    # this is required if you want to use darwin's default shell - zsh
    programs.zsh.enable = true;
    environment.shells = [
      pkgs.zsh
    ];

    # homebrew need to be installed manually, see https://brew.sh
    # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
    homebrew = {
      enable = true; # disable homebrew for fast deploy

      onActivation = {
        autoUpdate = true;
        # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
        cleanup = "zap";
      };

      # Applications to install from Mac App Store using mas.
      # You need to install all these Apps manually first so that your apple account have records for them.
      # otherwise Apple Store will refuse to install them.
      # For details, see https://github.com/mas-cli/mas
      masApps = {
      };

      taps = [
        "homebrew/cask-fonts"
        "homebrew/services"
        "homebrew/cask-versions"

        "hashicorp/tap"

        "danielfoehrkn/switch"
        "jwt-rs/jwt-ui"
      ];

      brews = [
        # `brew install`
        "wget" # download tool
        "curl" # no not install curl via nixpkgs, it's not working well on macOS!
        "direnv"
        "watch"

        # Usage:
        #  https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS#run-the-tailscaled-daemon
        # 1. `sudo tailscaled install-system-daemon`
        # 2. `tailscale up --accept-routes`
        "tailscale" # tailscale

        # https://github.com/rgcr/m-cli
        "m-cli" #  Swiss Army Knife for macOS

        # commands like `gsed` `gtar` are required by some tools
        "gnu-sed"
        "gnu-tar"

        "stow"

        "yarn"
        "nvm"

        # temporary until installer fix is merged into nixpkgs
        "danielfoehrkn/switch/switch"

        "jwt-ui"
      ];

      # `brew install --cask`
      casks = [
        "firefox"
        "visual-studio-code"
        "postman"

        "lookaway" # Eye strain reminders
        "jordanbaird-ice" # Menu bar tool

        # Terminals
        "ghostty"

        # Misc
        "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      ];
    };
  }
