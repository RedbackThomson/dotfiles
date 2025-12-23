# Base Home Manager Configuration

This directory contains the base Home Manager configuration modules that are shared across different platforms (macOS, Linux).

## Structure

The base configuration is organized into the following subdirectories:

### [core/](core/)

Core system utilities and tools that are essential for any environment:

- **Shell tools**: Modern CLI replacements (eza, bat, ripgrep, fd, fzf, delta)
- **Languages**: Development language configurations (Go, Python, Rust, Bun, KCL)
- **Editors**: Editor configurations (Neovim)
- **Apps**: Application configurations (1Password)
- **Git**: Git configuration
- **SSH**: SSH configuration
- **Container**: Container tools (Docker, Podman)
- **Starship**: Shell prompt configuration
- **AI**: AI-related tools
- **Other utilities**: btop, gnupg, gnumake, etc.

Includes shell enhancements like zoxide (smart cd), atuin (shell history), and nix-specific tools.

### [gui/](gui/)

GUI applications and configurations:

- **Terminal emulators**: Kitty, Ghostty
- **Development tools**: GUI-based development utilities

### [tui/](tui/)

Terminal UI applications and tools:

- **Terminal multiplexers**: Zellij
- **Monitoring**: k9s (Kubernetes)
- **Cloud tools**: Cloud platform CLI tools
- **Encryption**: Encryption-related utilities
- **Development tools**: Terminal-based development utilities

## Main Files

- [home.nix](home.nix): Base Home Manager configuration that sets up the username and state version

## Usage

This base configuration is imported by platform-specific configurations (e.g., darwin, linux) which can then add or override settings as needed. Each subdirectory uses `mylib.scanPaths` to automatically import all `.nix` files within it.

## Adding New Configurations

To add new tools or configurations:

1. Choose the appropriate category (core/gui/tui)
2. Add a new `.nix` file in that directory or subdirectory
3. The file will be automatically imported via `mylib.scanPaths`
