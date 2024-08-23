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
        format = "[$context \($namespace\)]($style)";
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
        "$conda"
        "$spack"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$openstack"
        "$azure"
        "$env_var"
        "$crystal"
        "$custom"
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
