FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="chris" \
    SHELL="/bin/zsh" \
    CLR_ICU_VERSION_OVERRIDE=71.1

RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen \
    && sudo pacman -Sy --noprogressbar --noconfirm --needed archlinux-keyring \
    && sudo pacman -Scc \
    && sudo rm -Rf /etc/pacman.d/gnupg \
    && sudo pacman-key --init \
    && sudo pacman-key --populate archlinux

RUN pacman -Syu --noprogressbar --noconfirm --needed \
       cmake clang unzip ninja git curl wget openssh zsh reflector \
    && useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && sudo reflector -p https -c us --score 20 --connection-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist \
    && wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
        -o /usr/share/ca-certificates/trust-source/rds-combined-ca-bundle.pem \
    && update-ca-trust

USER chris
WORKDIR /home/chris/

RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noprogressbar --noconfirm \
    && cd .. \
    && rm -Rf yay

# Base pacakages for neovim and terminal
RUN yay -Syu --noprogressbar --noconfirm --needed \
        python3 python-pip nodejs-lts-gallium npm clang \
        eslint_d prettier stylua git-delta github-cli \
        tmux bat fzf fd ripgrep kitty-terminfo \
        neovim neovim-remote nvim-packer-git \
        oh-my-zsh-git spaceship-prompt zsh-autosuggestions \
        aws-cli-v2-bin aws-session-manager-plugin aws-vault pass \
        docker docker-compose lazydocker \
        ncdu glances nnn-nerd jq zoxide-git \
    && sudo pip --disable-pip-version-check install pynvim \
    && sudo npm install -g neovim wip \
    && yay -Scc --noprogressbar --noconfirm

# Job specific packages
RUN yay -Syu --noprogressbar --noconfirm --needed \
       # dotnet-host-bin dotnet-sdk-bin aspnet-runtime-bin \
       # dotnet-runtime-bin netcoredbg \
       # mssql-tools maven ng \
        doppler-cli-bin terraform yarn redis \
        psqlodbc time prettierd \
    && terraform -install-autocomplete \
    && yay -Scc --noprogressbar --noconfirm

# netcoredbg (csharp debugger) has conflicts when it's part of the block above
# RUN yay -Syu --noprogressbar --noconfirm --needed netcoredbg \
#    && yay -Scc --noprogressbar --noconfirm

# I don't know why I have to set this again, but I do...
RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen

# This probably only needs to be run on the host
# RUN echo fs.inotify.max_user_watches=524288 \
#    | sudo tee /etc/sysctl.d/40-max-user-watches.conf \
#      && sudo sysctl --system

ENV TZ="America/Chicago"
ENV TERM="xterm-256color"
