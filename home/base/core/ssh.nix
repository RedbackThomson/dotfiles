{mysecrets, ...}: {
  programs.ssh = {
    enable = true;
    # Former HM defaults (see programs.ssh.enableDefaultConfig); set explicitly
    # so future removal of enableDefaultConfig does not change behavior.
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = true;
        ServerAliveInterval = 60;
        # Disable control master since it was causing bad responses with
        # multiple deployments
        ControlMaster = "no";
        ControlPersist = "30m";
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlPath = "~/.ssh/master-%r@%n:%p";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        ForwardAgent = false;
        PreferredAuthentications = "publickey";
      };
    };
  };
}
