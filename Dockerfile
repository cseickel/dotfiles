FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    SHELL="/bin/zsh" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

COPY ./rds-ca-2019-root.crt /usr/share/ca-certificates/trust-source/rds-ca-2019-root.crt

RUN pacman -Syu --noprogressbar --noconfirm --needed \
       git python3 python-pip nodejs npm wget curl \
       tmux zsh bat fzf openssh \
    && update-ca-trust \
    && useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && pacman -Scc --noprogressbar --noconfirm

USER arch
WORKDIR /home/arch

RUN cd /home/$UNAME \
    && git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noprogressbar --noconfirm \
    && cd .. \
    && rm -Rf yay

RUN yay -Syu --noprogressbar --noconfirm \
       neovim-nightly-bin neovim-plug neovim-remote \
       oh-my-zsh-git spaceship-prompt \
       aspnet-runtime-3.1 dotnet-sdk-3.1 aws-cli-v2-bin \
       ripgrep docker docker-compose tree-sitter aws-vault pass \
       ncdu glances nnn-nerd neovim-symlinks \
    && sudo pip --disable-pip-version-check install pynvim \
    && sudo npm install -g @angular/cli aws-cdk neovim ng wip \
    && yay -Scc --noprogressbar --noconfirm

RUN cd /home/$UNAME \
    && mkdir -p .config/nvim/colors \
    && mkdir -p .config/nvim/UltiSnips \
    && git clone https://github.com/cseickel/dotfiles.git .dotfiles \
    && /bin/sh /home/$UNAME/.dotfiles/install \
    && git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm \
    && ~/.tmux/plugins/tpm/scripts/install_plugins.sh \
    && nvim --headless -u ~/.config/nvim/plugin-install.vim -c "PlugInstall | qa" \
    && nvim --headless +qa \
    && mkdir -p /home/$UNAME/.gnupg \
    && echo "default-cache-ttl 3600" > /home/$UNAME/.gnupg/gpg-agent.conf \
    && echo "max-cache-ttl 57600" >> /home/$UNAME/.gnupg/gpg-agent.conf

# This probably only needs to be run on the host
# RUN echo fs.inotify.max_user_watches=524288 \
#    | sudo tee /etc/sysctl.d/40-max-user-watches.conf \
#      && sudo sysctl --system

ARG CACHE_BREAKER=""
RUN yay -Syu --noprogressbar --noconfirm \
    && yay -Scc --noprogressbar --noconfirm

ENV TERM xterm-256color
