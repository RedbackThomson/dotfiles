let
  envExtra = ''
    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
  '';
  # Load zshrc content for any Homebrew installed packages.
  initContent = ''
    arch=$(uname -m)

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    source <(compdef _switcher switch)

    if command -v "switcher" >/dev/null 2>&1; then
      source <(switcher init zsh)
      source <(switch completion zsh)
    fi
  '';
in {
  # Homebrew's default install location:
  #   /opt/homebrew for Apple Silicon
  #   /usr/local for macOS Intel
  # The prefix /opt/homebrew was chosen to allow installations
  # in /opt/homebrew for Apple Silicon and /usr/local for Rosetta 2 to coexist and use bottles.
  programs.bash = {
    enable = true;
    bashrcExtra = envExtra + initContent;
  };
  programs.zsh = {
    enable = true;
    inherit envExtra initContent;
  };
}
