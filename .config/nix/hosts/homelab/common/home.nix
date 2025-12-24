{ pkgs, ...}: {
  myconfig = {
    core = {
      containers.basic.enable = true;
      containers.advanced.enable = true;
      cloudProviders.aws.enable = true;
      utilities.enable = true;
    };
  };
}
