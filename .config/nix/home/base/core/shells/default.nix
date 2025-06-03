{
  config,
  pkgs,
  ...
}: let
  shellAliases = {
    k = "kubectl";
    kubectx = "switch";
    grep = "grep --color=always";
    s = "switch";
    cat = "bat";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
in {
  home.shellAliases = shellAliases;

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    history.path = "${config.xdg.dataHome}/zsh/.zsh_history";
    history.size = 100000;

    enableCompletion = true;

    autosuggestion = {
      enable = true;
    };

    syntaxHighlighting = {
      enable = true;
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
    localVariables = {
      ZSH_AUTOSUGGEST_STRATEGY = ["history" "completion"];
    };
    initContent = builtins.readFile ./.zshrc;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
    '';
  };
}
