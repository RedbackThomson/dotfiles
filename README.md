# dotfiles
Dot files for my environments

## Installation
```
# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install dotfiles
git clone https://github.com/RedbackThomson/dotfiles.git
cd dotfiles
sh bootstrap.sh

# Install neovim
sudo yum install -y python3-{devel,pip}
sudo pip-3 install neovim --upgrade
sudo yum install -y neovim

# Install neobundle
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > install.sh
sh ./install.sh
```
