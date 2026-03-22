{mysecrets, ...}: {
  programs.ssh = {
    enable = true;
    # Former HM defaults (see programs.ssh.enableDefaultConfig); set explicitly
    # so future removal of enableDefaultConfig does not change behavior.
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
        serverAliveInterval = 60;
        # Disable control master since it was causing bad responses with
        # multiple deployments
        controlMaster = "no";
        controlPersist = "30m";
        addKeysToAgent = "no";
        compression = false;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlPath = "~/.ssh/master-%r@%n:%p";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        forwardAgent = false;
        extraOptions = {preferredAuthentications = "publickey";};
      };
    };
  };
}
