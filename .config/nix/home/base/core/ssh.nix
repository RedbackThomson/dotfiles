{mysecrets, ...}: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    serverAliveInterval = 60;
    controlMaster = "auto";
    controlPersist = "30m";
    extraConfig = ''
      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        forwardAgent = false;
        extraOptions = { preferredAuthentications = "publickey"; };
      };
    };
  };
}
