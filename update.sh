#!/bin/bash
git --git-dir ~/.dotfiles/.git pull
~/.dotfiles/install
nvim --headless -u ~/.config/nvim/plugin-install.vim -c \
    "PlugUpgrade | echo '...' | PlugClean! | echo '...' | PlugInstall | echo '...' | PlugUpdate | TSUpdate | CocUpdate | qa" \
