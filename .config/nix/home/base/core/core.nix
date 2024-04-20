{
  pkgs,
  attic,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    # Misc
    gnupg
    gnumake

    # Morden cli tools, replacement of grep/sed/...

    # Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf
    # search for files by name, faster than find
    fd
    # search for files by its content, replacement of grep
    (ripgrep.override {withPCRE2 = true;})

    # A fast and polyglot tool for code searching, linting, rewriting at large scale
    # supported languages: only some mainstream languages currently(do not support nix/nginx/yaml/toml/...)
    ast-grep

    yq-go # yaml processer https://github.com/mikefarah/yq
    delta # A viewer for git and diff output

    # nix related
    #
    # it provides the command `nom` works just like `nix
    # with more details log output
    nix-output-monitor
    hydra-check # check hydra(nix's build farm) for the build status of a package
    nix-index # A small utility to index nix store paths
    nix-init # generate nix derivation from url
    # https://github.com/nix-community/nix-melt
    nix-melt # A TUI flake.lock viewer
    # https://github.com/utdemir/nix-tree
    nix-tree # A TUI to visualize the dependency graph of a nix derivation
  ];

  programs = {
    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      enableAliases = true; # do not enable aliases in nushell!
      git = true;
      icons = true;
    };

    # a cat(1) clone with syntax highlighting and Git integration.
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin-frappe";
      };
      themes = {
        # https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme
        catppuccin-frappe = {
          src = nur-ryan4yin.packages.${pkgs.system}.catppuccin-bat;
          file = "Catppuccin-frappe.tmTheme";
        };
      };
    };

    # A command-line fuzzy finder
    fzf = {
      enable = true;
      # https://github.com/catppuccin/fzf
      # catppuccin-frappe
      colors = {
        "bg+" = "#414559";
        "bg" = "#303446";
        "spinner" = "#f2d5cf";
        "hl" = "#e78284";
        "fg" = "#c6d0f5";
        "header" = "#e78284";
        "info" = "#ca9ee6";
        "pointer" = "#f2d5cf";
        "marker" = "#f2d5cf";
        "fg+" = "#c6d0f5";
        "prompt" = "#ca9ee6";
        "hl+" = "#e78284";
      };
    };

    # zoxide is a smarter cd command, inspired by z and autojump.
    # It remembers which directories you use most frequently,
    # so you can "jump" to them in just a few keystrokes.
    # zoxide works on all major shells.
    #
    #   z foo              # cd into highest ranked directory matching foo
    #   z foo bar          # cd into highest ranked directory matching foo and bar
    #   z foo /            # cd into a subdirectory starting with foo
    #
    #   z ~/foo            # z also works like a regular cd command
    #   z foo/             # cd into relative path
    #   z ..               # cd one level up
    #   z -                # cd into previous directory
    #
    #   zi foo             # cd with interactive selection (using fzf)
    #
    #   z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # Atuin replaces your existing shell history with a SQLite database,
    # and records additional context for your commands.
    # Additionally, it provides optional and fully encrypted
    # synchronisation of your history between machines, via an Atuin server.
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
