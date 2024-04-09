{
  pkgs,
  ...
}: {
  programs.oh-my-posh = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = builtins.fromJSON (
      builtins.unsafeDiscardStringContext (builtins.readFile ./omp.config.json)
    );
  };
}
