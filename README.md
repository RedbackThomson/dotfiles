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
