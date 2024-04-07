# dotfiles

Dot files for the RedbackThomson development environment

## Required Tools

- kitty
- zsh
- stow

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
brew install zoxide danielfoehrkn/switch/switch jandedobbeleer/oh-my-posh/oh-my-posh zsh-autosuggestions zsh-syntax-highlighting direnv
```

## Installation

Use `stow` to set up symlinks

```bash
git clone git@github.com:RedbackThomson/dotfiles.git
cd dotfiles
stow .
```