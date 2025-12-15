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
                    "(no description set)",
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
