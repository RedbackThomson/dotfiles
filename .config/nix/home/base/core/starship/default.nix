{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      aws.disabled = true;
      gcloud.disabled = true;
      golang.disabled = true;

      git_branch = {
        style = "fg:#81c8be";
      };

      directory = {
        style = "fg:#8caaee bold";
      };

      kubernetes = {
        format = "[$context \($namespace \)]($style)";
        style = "fg:#f4b8e4";
        disabled = false;

        contexts = [
          {
            context_pattern = "gke_.*_(?P<cluster>[\\w-]+)";
            context_alias = "󱇶/$cluster";
          }
          {
            context_pattern = "arn:aws:eks:.*:(?P<account_id>[0-9]{12}):cluster/(?P<cluster>[\\w-]+)$";
            context_alias = "󰸏/$account_id/$cluster";
          }
          {
            context_pattern = "kind-(?P<cluster>[\\w-]+)$";
            context_alias = "/$cluster";
          }
        ];
      };

      custom = {
        jj = {
          command = 
            ''
              jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                separate(" ",
                  change_id.shortest(4),
                  bookmarks,
                  "|",
                  concat(
                    if(conflict, "💥"),
                    if(divergent, "🚧"),
                    if(hidden, "👻"),
                    if(immutable, "🔒"),
                  ),
                  raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                  raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                    truncate_end(29, description.first_line(), "…"),
                    "(no desc)",
                  ) ++ raw_escape_sequence("\x1b[0m"),
                )
              '
            '';
          when = "jj --ignore-working-copy root";
          symbol = " ";
        };
      };

      # optionally disable git modules
      git_state.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;

      # re-enable git_branch as long as we're not in a jj repo
      custom.git_branch = {
        when = true;
        command = "jj root >/dev/null 2>&1 || starship module git_branch";
        description = "Only show git_branch if we're not in a jj repo";
      };

      # Remove versions from all runtimes
      bun.format = "via [$symbol]($style)";
      buf.format = "with [$symbol]($style)";
      c.format = "via [$symbol($name)]($style)";
      cmake.format = "via [$symbol]($style)";
      cobol.format = "via [$symbol]($style)";
      cpp.format = "via [$symbol($name)]($style)";
      crystal.format = "via [$symbol]($style)";
      daml.format = "via [$symbol]($style)";
      dart.format = "via [$symbol]($style)";
      deno.format = "via [$symbol]($style)";
      dotnet.format = "[$symbol(🎯 $tfm )]($style)";
      elixir.format = "via [$symbol]($style)";
      elm.format = "via [$symbol]($style)";
      erlang.format = "via [$symbol]($style)";
      fennel.format = "via [$symbol]($style)";
      gleam.format = "via [$symbol]($style)";
      golang.format = "via [$symbol]($style)";
      gradle.format = "via [$symbol]($style)";
      haskell.format = "via [$symbol]($style)";
      haxe.format = "via [$symbol]($style)";
      helm.format = "via [$symbol]($style)";
      java.format = "via [$symbol]($style)";
      julia.format = "via [$symbol]($style)";
      kotlin.format = "via [$symbol]($style)";
      lua.format = "via [$symbol]($style)";
      meson.format = "via [$symbol]($style)";
      mojo.format = "with [$symbol]($style)";
      nim.format = "via [$symbol]($style)";
      nodejs.format = "via [$symbol]($style)";
      ocaml.format = "via [$symbol(\($switch_indicator$switch_name\) )]($style)";
      odin.format = "via [$symbol]($style)";
      opa.format = "via [$symbol]($style)";
      perl.format = "via [$symbol]($style)";
      php.format = "via [$symbol]($style)";
      pixi.format = "via [$symbol($environment )]($style)";
      pulumi.format = "via [$symbol$stack]($style)";
      purescript.format = "via [$symbol]($style)";
      python.format = "via [$symbol]($style)";
      quarto.format = "via [$symbol]($style)";
      raku.format = "via [$symbol]($style)";
      red.format = "via [$symbol]($style)";
      rlang.format = "via [$symbol]($style)";
      ruby.format = "via [$symbol]($style)";
      rust.format = "via [$symbol]($style)";
      scala.format = "via [$symbol]($style)";
      solidity.format = "via [$symbol]($style)";
      swift.format = "via [$symbol]($style)";
      typst.format = "via [$symbol]($style)";
      vagrant.format = "via [$symbol]($style)";
      vlang.format = "via [$symbol]($style)";
      zig.format = "via [$symbol]($style)";

      format = lib.concatStrings [
        " " # added
        "$username"
        "$hostname"
        "$localip"
        "$shlvl"
        "$singularity"
        "$kubernetes" # moved
        "$directory"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "\${custom.jj}"
        "$hg_branch"
        "$docker_context"
        "$package"
        "$buf"
        "$c"
        "$cmake"
        "$cobol"
        "$container"
        "$daml"
        "$dart"
        "$deno"
        "$dotnet"
        "$elixir"
        "$elm"
        "$erlang"
        "$golang"
        "$haskell"
        "$helm"
        "$java"
        "$julia"
        "$kotlin"
        "$lua"
        "$nim"
        "$nodejs"
        "$ocaml"
        "$perl"
        "$php"
        "$pulumi"
        "$purescript"
        "$python"
        "$rlang"
        "$red"
        "$ruby"
        "$rust"
        "$scala"
        "$swift"
        "$terraform"
        "$vlang"
        "$vagrant"
        "$zig"
        "$nix_shell"
        "$nats" # Added
        "$conda"
        "$spack"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$openstack"
        "$azure"
        "$env_var"
        "$crystal"
        # "$custom" # Removed - use individual custom modules instead
        "$sudo"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$shell"
        "$character"
      ];
    };
  };
}
