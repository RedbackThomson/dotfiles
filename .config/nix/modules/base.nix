{
  pkgs,
  myvars,
  nuenv,
  ...
} @ args: {
  environment.systemPackages = with pkgs; [
    git # used by nix flakes
    git-lfs # used by huggingface models

    # archives
    zip
    xz
    zstd
    unzip
    p7zip

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    gawk # GNU awk, a pattern scanning and processing language
    jq # A lightweight and flexible command-line JSON processor

    # networking tools
    iperf3
    dnsutils # `dig` + `nslookup`
    wget
    curl
    nmap # A utility for network discovery and security auditing

    # misc
    file
    findutils
    which
    tree
    gnutar
    rsync
  ];

  users.users.${myvars.username} = {
    description = myvars.userfullname;
  };

  # Disable nix management through nix-darwin in favour of nix-determinate
  nix.enable = false;

  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = [myvars.username];
  };
}
