{
  pkgs,
  ...
}: {
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
}
