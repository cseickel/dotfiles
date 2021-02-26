#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# start ssh-agent
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/*id_rsa
fi
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
	tmux attach || exec tmux && exit;
fi
