{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.myconfig.core.ai.enable {
    home.packages = with pkgs; [
    ];

    # mkAfter so this runs after 1password.nix defines the gh() plugin function.
    programs.zsh.initContent = lib.mkAfter ''
      # gh uses GH_TOKEN in Claude, so drop the biometric plugin function there.
      if [[ -n "$CLAUDE_SESSION" ]]; then
        unfunction gh 2>/dev/null
      fi

      claude() {
        local _gh_token
        _gh_token="$(op read 'op://Upbound/GitHub Claude Access Token/token' 2>/dev/null)" \
          || echo "warning: op read failed; launching Claude without GH_TOKEN" >&2
        CLAUDE_SESSION=1 GH_TOKEN="$_gh_token" command claude "$@"
      }
    '';
  };
}
