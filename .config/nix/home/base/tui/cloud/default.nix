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
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])

    # azure
    azure-cli
  ];
}
