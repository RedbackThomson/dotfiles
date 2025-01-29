{
  mylib,
  pkgs-unstable,
  ...
}: {
  imports = mylib.scanPaths ./.;

  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    extensions = [
      "catppuccin"
      "dockerfile"
      "env"
      "git-firefly"
      "golangci-lint"
      "gosum"
      "make"
      "mermaid"
      "nix"
      "starlark"
    ];
    userSettings = {
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
      };
      theme = "Catppuccin Frappé";
      vim_mode = false;
      buffer_font_family = "MonaspiceNe Nerd Font Mono";
      buffer_font_features = {
        "calt" = true;
        "liga" = true;
      };
      buffer_font_size = 13;
      git = {
        inline_blame.enabled = true;
      };
      file_types = {
        "Dockerfile" = ["Dockerfile*"];
        "Starlark" = ["Tiltfile"];
      };
      wrap_guides = [80];
      assistant.enabled = false;
      ui_font_family = "MonaspiceNe Nerd Font Mono";
      ui_font_features = {
        "calt" = true;
        "liga" = true;
      };
      collaboration_panel.button = false;
      chat_panel.button = false;
      assistant = {
        version = "2";
        button = false;
      };
    };
  };
}
