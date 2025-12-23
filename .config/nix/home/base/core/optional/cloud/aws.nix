{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.core.cloudProviders.aws.enable {
    home.packages = with pkgs; [
      awscli2
      ssm-session-manager-plugin
      aws-iam-authenticator
      eksctl
    ];
  };
}
