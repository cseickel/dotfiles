FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    SHELL="/bin/zsh" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen

RUN pacman -Syu --noprogressbar --noconfirm --needed \
       cmake clang unzip ninja git curl wget openssh zsh reflector \
    && useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && sudo reflector -p https -c us --score 20 --connection-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist \
    && wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
        -o /usr/share/ca-certificates/trust-source/rds-combined-ca-bundle.pem \
    && update-ca-trust

USER arch
WORKDIR /home/arch

RUN cd /home/$UNAME \
    && git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noprogressbar --noconfirm \
    && cd .. \
    && rm -Rf yay

# The following lines can be run repeatedly to update everything
# just CACHE_BREAKER to todays date or something similar and rebuild
ARG CACHE_BREAKER=""

RUN yay -Syu --noprogressbar --noconfirm --needed \
        python3 python-pip nodejs npm clang eslint_d prettier git-delta github-cli \
        tmux bat fzf kitty-terminfo neovim-nightly-bin neovim-remote nvim-packer-git \
        oh-my-zsh-git spaceship-prompt zsh-autosuggestions \
        aspnet-runtime-3.1 dotnet-sdk-3.1 aws-cli-v2-bin aws-session-manager-plugin \
        ripgrep docker docker-compose aws-vault pass \
        ncdu glances nnn-nerd mssql-tools jq zoxide-git lazydocker \
	code-server netcoredbg \
    && sudo pip --disable-pip-version-check install pynvim \
    && sudo npm install -g @angular/cli aws-cdk neovim ng wip \
    && yay -Scc --noprogressbar --noconfirm

# I don't know why I have to set this again, but I do...
RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen

# This probably only needs to be run on the host
# RUN echo fs.inotify.max_user_watches=524288 \
#    | sudo tee /etc/sysctl.d/40-max-user-watches.conf \
#      && sudo sysctl --system

ENV TERM="xterm-256color" \
    PORT=8888

CMD [ "/usr/bin/code-server", "--auth",  "none" ]
