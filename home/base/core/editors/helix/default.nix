{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.myconfig.editors.helix.enable {
    programs.helix = {
      enable = true;

      settings = {
        theme = "catppuccin_frappe";

        editor = {
          line-number = "relative";
          rulers = [80];
          cursorline = true;
          scrolloff = 8;

          # Yanks and pastes go through the system clipboard.
          default-yank-register = "+";

          # Only errors render in the buffer; warnings and below stay in the
          # diagnostics picker.
          end-of-line-diagnostics = "error";
          inline-diagnostics.cursor-line = "error";

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };
        };
      };

      # Servers helix's built-in language config expects on PATH.
      extraPackages = with pkgs; [
        gopls
        nil
        nodejs
        rust-analyzer
        typescript-language-server
      ];
    };
  };
}
