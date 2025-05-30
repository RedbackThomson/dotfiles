# Nix Dotfiles Structure (Simplified)

This repository uses a simplified structure for Nix-based dotfiles:

- `profiles/` — One file per host (e.g., `work-laptop.nix`, `personal-mac.nix`). Each file imports shared modules and adds host-specific settings.
- `modules/` — Shared configs for editors, shells, languages, apps, etc. These are imported as needed by each profile.
- `secrets/` — For sensitive files (SSH keys, etc.), not tracked by git.

**Note:** The old `hosts/` and `home/` directories are being replaced by `profiles/` and `modules/`.

Example:

```
.config/nix/
  profiles/
    work-laptop.nix
    personal-mac.nix
  modules/
    neovim.nix
    zsh.nix
    starship.nix
    # ...other shared configs...
  secrets/         # (gitignored, for SSH keys, etc.)
    id_ed25519_work
    id_ed25519_work.pub
  flake.nix        # (if using flakes)
  home.nix         # (optional, for shared imports)
```

See below for details on each directory and how to use them.

# Migration Checklist

- [ ] Move shared configs from `home/base/core/` and related directories to `modules/`.
- [ ] Move host-specific configs from `hosts/` to `profiles/` (one file per host).
- [ ] Move secrets (e.g., SSH keys) to `secrets/` and ensure they are gitignored.
- [ ] Update `flake.nix` or entrypoint to use the new `profiles/` and `modules/` structure.
- [ ] Remove or archive the old `home/` and `hosts/` directories after migration.

# Example: profiles/work-laptop.nix

```nix
{ config, pkgs, ... }:
{
  imports = [
    ../modules/neovim.nix
    ../modules/zsh.nix
    ../modules/starship.nix
    ./ssh-keys.nix
  ];

  # Host-specific settings
  home.username = "nicholasthomson";
  home.homeDirectory = "/Users/nicholasthomson";
  # ...other host-specific options...
}
```

# Example: modules/neovim.nix

```nix
{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    # ...other neovim settings...
  };
}
```

# Example: profiles/ssh-keys.nix

```nix
{ config, ... }:
{
  home.file.".ssh/id_ed25519".source = ../../secrets/id_ed25519_work;
  home.file.".ssh/id_ed25519.pub".source = ../../secrets/id_ed25519_work.pub;
}
```

# Example: flake.nix homeConfigurations entry

```nix
homeConfigurations = {
  "nicholasthomson@work-laptop" = home-manager.lib.homeManagerConfiguration {
    inherit system;
    homeDirectory = "/Users/nicholasthomson";
    username = "nicholasthomson";
    configuration = import ./profiles/work-laptop.nix;
  };
  # ...other hosts...
};
``` 