#!/bin/bash
# run tmux if it's not already running
[ -z "${TMUX}" ] && tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || git -C ~/.tmux/plugins/tpm pull
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux source ~/.tmux.conf
