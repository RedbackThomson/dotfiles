{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}:
let
  hostName = "homelab-0-k3s-0"; # Define your hostname.

  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # the first node in the cluster should be the one to initialize the cluster
    clusterInit = true;
    masterHost = "homelab-0-k3s-0.homelab.local";
    # k3sExtraArgs = [
    #   # IPv4 Private CIDR(full) - 172.16.0.0/12
    #   # IPv4 Pod     CIDR(full) - fdfd:cafe:00:0000::/64 ~ fdfd:cafe:00:7fff::/64
    #   # IPv4 Service CIDR(full) - fdfd:cafe:00:8000::/64 ~ fdfd:cafe:00:ffff::/64
    #   "--cluster-cidr=172.20.0.0/16,fdfd:cafe:00:0003::/64"
    #   "--service-cidr=172.21.0.0/16,fdfd:cafe:00:8003::/112"
    # ];
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    k3sModule
  ];
}