{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose

    argocd
    fluxcd
    istioctl
    kind
    kubectl
    kubernetes-helm
    kubeswitch
    tilt
  ];

  programs = {
    k9s = {
      enable = true;

      # https://k9scli.io/topics/aliases/
      aliases = {
        dp = "deployments";
        sec = "v1/secrets";
        jo = "jobs";
        cr = "clusterroles";
        crb = "clusterrolebindings";
        ro = "roles";
        rb = "rolebindings";
        np = "networkpolicies";
      };
      settings = {
        skin = "catppuccino-mocha";
      };
      # skins.catppuccin-mocha = let
      #   skin_file = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-k9s}/dist/mocha.yml"; # theme - catppuccin mocha
      #   skin_attr = builtins.fromJSON (
      #     builtins.readFile
      #     # replace 'base: &base "#1e1e2e"' with 'base: &base "default"'
      #     # to make fg/bg color transparent. "default" means transparent in k9s skin.
      #     (pkgs.runCommandNoCC "get-skin-json" {} ''
      #       cat ${skin_file} \
      #         |  sed -E 's@(base: &base ).+@\1 "default"@g' \
      #         | ${pkgs.yj}/bin/yj > $out
      #     '')
      #   );
      # in
      #   skin_attr;
    };
  };
}
