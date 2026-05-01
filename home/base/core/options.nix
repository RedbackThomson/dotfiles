{lib, ...}: {
  options.myconfig = {
    core = {
      # Essential tools - enabled by default for backwards compatibility
      essential.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Essential CLI tools (ripgrep, fd, fzf, bat, eza, zoxide, atuin)";
      };

      git = {
        enable = lib.mkEnableOption "Git tools (git)";
        jujutsu.enable = lib.mkEnableOption "Jujutsu";
      };

      # Container/K8s tools (split into basic and advanced)
      containers = {
        basic.enable = lib.mkEnableOption "Basic container/K8s tools (kubectl, helm, k9s)";
        advanced.enable = lib.mkEnableOption "Advanced K8s tools (argocd, fluxcd, istio, tilt, cosign, trivy)";
      };

      # Cloud provider CLIs (individually optional)
      cloudProviders = {
        aws.enable = lib.mkEnableOption "AWS CLI and tools";
        gcp.enable = lib.mkEnableOption "Google Cloud SDK";
        azure.enable = lib.mkEnableOption "Azure CLI";
        digitalocean.enable = lib.mkEnableOption "DigitalOcean CLI";
      };

      # DevOps and utility tools
      devops.enable = lib.mkEnableOption "DevOps tools (terraform, earthly)";
      utilities.enable = lib.mkEnableOption "Utility tools (neofetch, vhs, viddy, cloc, ncdu)";

      ai.enable = lib.mkEnableOption "AI tools (chatgpt, claude, grok)";
    };

    databases = {
      mongodb.enable = lib.mkEnableOption "MongoDB CLI";
      postgresql.enable = lib.mkEnableOption "PostgreSQL CLI";
      mysql.enable = lib.mkEnableOption "MySQL CLI";
      sqlite.enable = lib.mkEnableOption "SQLite CLI";
    };

    languages = {
      bun.enable = lib.mkEnableOption "Bun JavaScript runtime";
      go.enable = lib.mkEnableOption "Go programming language";
      rust.enable = lib.mkEnableOption "Rust programming language";
      python.enable = lib.mkEnableOption "Python programming language";
      kcl.enable = lib.mkEnableOption "KCL configuration language";
    };
  };
}
