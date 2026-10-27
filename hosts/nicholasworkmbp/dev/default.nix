{
  lib,
  writeShellApplication,
  replaceVars,
  coreutils,
  findutils,
  fzf,
  jq,
  jujutsu,
  zellij,
  zjstatus,
  zj-radar,
  repoRoot ? "",
}: let
  layout = replaceVars ./dev.kdl {
    inherit zjstatus;
    zj_radar = zj-radar;
  };
  runtimeInputs = [
    coreutils
    findutils
    fzf
    jq
    jujutsu
    zellij
  ];
in
  writeShellApplication {
    name = "dev";
    inherit runtimeInputs;

    text = ''
      DEV_DEFAULT_REPO_ROOT=${lib.escapeShellArg (toString repoRoot)}
      DEV_ZELLIJ_LAYOUT=''${DEV_ZELLIJ_LAYOUT:-${layout}}
      DEV_RUNTIME_PATH=${lib.escapeShellArg (lib.makeBinPath runtimeInputs)}
      ${builtins.readFile ./dev.sh}
    '';

    meta = {
      description = "Start and manage Jujutsu workspaces in Zellij sessions";
      mainProgram = "dev";
      platforms = lib.platforms.darwin;
    };
  }
