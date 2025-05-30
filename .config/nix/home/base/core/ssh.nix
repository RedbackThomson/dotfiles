{mysecrets, ...}: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    serverAliveInterval = 60;
    controlMaster = "auto";
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
