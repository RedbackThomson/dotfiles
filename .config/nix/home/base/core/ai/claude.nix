{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.myconfig.core.ai.enable {
    home.packages = with pkgs; [
      pkgs.claude-code
    ];
  };
}
