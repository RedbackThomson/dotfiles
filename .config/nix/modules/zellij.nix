# ... existing code from home/base/tui/zellij/default.nix ...
{pkgs, ...}: let
  shellAliases = {
    "zj" = "zellij";
  };
in {
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
  };

  home.shellAliases = shellAliases;

  xdg = {
    configFile = {
      "zellij/config.kdl".source = ./config.kdl;
      "zellij/layouts/default.kdl".text = ''
        layout {
          default_tab_template {
            children
            pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                hide_frame_for_single_pane "true"

                format_left  "{mode}#[fg=#8caaee] {session} {tabs}"
                format_right "{datetime}"
                format_space ""

                mode_normal          "#[bg=#8caaee] "
                mode_tmux            "#[bg=#e5c890] "
                mode_default_to_mode "tmux"

                tab_normal               "#[fg=#838ba7] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_active               "#[fg=#a6d189,bold] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_fullscreen_indicator "□ "
                tab_sync_indicator       "  "
                tab_floating_indicator   "󰉈 "

                datetime          "#[fg=#949cbb] {format} "
                datetime_format   "%A, %d %b %Y %H:%M"
                datetime_timezone "America/Los_Angeles"
              }
            }
          }
        }
      '';
      "zellij/layouts/ops.kdl".text = ''
        layout {
          tab_template name="upbound_ops_tab" {
            pane split_direction="Vertical" {
              pane name="Scratch"
              pane name="K9s" {
                children
              }
            }
            pane name="K9s"
            pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                hide_frame_for_single_pane "true"

                format_left  "{mode}#[fg=#8caaee] {session} {tabs}"
                format_right "{datetime}"
                format_space ""

                mode_normal          "#[bg=#8caaee] "
                mode_tmux            "#[bg=#e5c890] "
                mode_default_to_mode "tmux"

                tab_normal               "#[fg=#838ba7] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_active               "#[fg=#a6d189,bold] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_fullscreen_indicator "□ "
                tab_sync_indicator       "  "
                tab_floating_indicator   "󰉈 "

                datetime          "#[fg=#949cbb] {format} "
                datetime_format   "%A, %d %b %Y %H:%M"
                datetime_timezone "America/Los_Angeles"
              }
            }
          }
          upbound_ops_tab name="Dev" focus=true
          upbound_ops_tab name="Staging"
          upbound_ops_tab name="Production"
          tab name="Jumps" {
            pane name="jump_dev"
            pane name="jump_staging"
            pane name="jump_prod"
          }
        }
      '';
    };
  };
}
