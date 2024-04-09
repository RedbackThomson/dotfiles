{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # aws
    awscli2
    ssm-session-manager-plugin # Amazon SSM Session Manager Plugin
    aws-iam-authenticator
    eksctl

    # gcp
    google-cloud-sdk

    # azure
    azure-cli
  ];
}
