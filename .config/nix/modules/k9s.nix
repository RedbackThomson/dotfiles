# ... existing code from home/base/tui/k9s/default.nix ...
{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}: {
  programs.k9s = {
    enable = true;
    package = pkgs-unstable.k9s;
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
  };

  # the file naming conventions for the current k9s nix package use `.yml`
  # instead of `.yaml`
  xdg = {
    configFile = {
      "k9s/config.yaml".source = ./settings.yaml;
      "k9s/plugins.yaml".source = ./plugins.yaml;
      "k9s/skins/catppuccin-frappe.yaml" = {
        source = "${
          pkgs-unstable.catppuccin.override {
            themeList = ["k9s"];
            variant = "frappe";
            accent = "sapphire";
          }
        }/k9s/catppuccin-frappe.yaml";
      };
    };
  };
}
