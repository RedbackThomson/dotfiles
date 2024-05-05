{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "pibox.local" = {
        hostname = "pibox.local";
        user = "pibox";
        forwardAgent = false;
      };
    };
  };
}
