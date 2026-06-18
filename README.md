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