{mysecrets, ...}: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    serverAliveInterval = 60;

    # Disable control master since it was causing bad responses with multiple
    # deployments
    controlMaster = "no";
    controlPersist = "30m";

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        forwardAgent = false;
        extraOptions = {preferredAuthentications = "publickey";};
      };
    };
  };
}
