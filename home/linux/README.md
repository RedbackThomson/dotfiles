# Home Manager's Linux Submodules

This directory contains Linux-specific Home Manager configurations organized for
different use cases.

## Configuration Modules

### Core Configurations

- **core.nix**: Essential Linux-specific configurations and settings
- **base/**: Base Linux configurations including shell, tools, and utilities
  - `shell.nix`: Shell configurations and aliases
  - `tools.nix`: Essential command-line tools and utilities

### Available Entry Points

- **core.nix**: Core Linux configuration, suitable for basic setups
- **tui.nix**: Terminal-based interface configuration for lightweight environments
- **gui.nix**: Graphical user interface configuration entry point, imports
  desktop environments (🚧 WIP)

## Usage

- **Lightweight/Terminal**: Use `core.nix` or `tui.nix` for terminal-focused setups
- **Desktops**: Use `gui.nix` for full desktop environments with window managers like Hyprland or
  Niri
- **Custom**: Mix and match configurations as needed for your specific use case