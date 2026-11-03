# dotfiles

Dot files for the RedbackThomson development environment

## Required Tools

Install nix CLI using [`The Determinate Nix Installer`][https://github.com/DeterminateSystems/nix-installer]:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Installation

Use the `darwin-rebuild` exposed by this flake to switch to the config.

```bash
sudo nix run .#darwin-rebuild -- switch --flake .
```

## Updating

After the first switch, `darwin-rebuild` is on your `PATH`:

```bash
sudo darwin-rebuild switch --flake ~/dotfiles
```

After bumping the `nix-darwin` input, use the `nix run` form above once so the
switch runs with the new `darwin-rebuild`.

## Deploying remote hosts

The NixOS hosts under `outputs/x86_64-linux/` deploy over SSH with
[Colmena](https://github.com/zhaofengli/colmena). Each host builds its own
config, so you can deploy from macOS. SSH connects as `root`, so your key must be
in each host's `root` authorized keys.

Run these from the repo root. `nix run .#colmena` uses the Colmena version
pinned in this flake.

Deploy every host:

```bash
nix run .#colmena -- apply
```

Deploy one host by name:

```bash
nix run .#colmena -- apply --on homelab-0-devbox
```

Deploy several hosts by glob, or by tag with `@`:

```bash
nix run .#colmena -- apply --on 'homelab-0-k3s-*'
```

```bash
nix run .#colmena -- apply --on @k3s
```

Build without activating, to check that a config builds:

```bash
nix run .#colmena -- build --on homelab-0-k3s-0
```

Activate on the next boot instead of right away, for kernel or bootloader
changes:

```bash
nix run .#colmena -- apply boot --on homelab-0-k3s-1
```

Run a command on hosts:

```bash
nix run .#colmena -- exec --on 'homelab-0-k3s-*' -- systemctl status k3s
```
