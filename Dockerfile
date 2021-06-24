FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    SHELL="/bin/zsh" \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

COPY ./rds-ca-2019-root.crt /usr/share/ca-certificates/trust-source/rds-ca-2019-root.crt

RUN pacman -Syu --noprogressbar --noconfirm --needed \
       cmake clang unzip ninja git curl wget openssh zsh \
    && update-ca-trust \
    && useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER arch
WORKDIR /home/arch

RUN cd /home/$UNAME \
    && git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -si --noprogressbar --noconfirm \
    && cd .. \
    && rm -Rf yay

RUN yay -Syu --noprogressbar --noconfirm --needed \
        python3 python-pip nodejs npm prettier git-delta \
        tmux bat fzf tree-sitter neovim-plug neovim-remote \
        oh-my-zsh-git spaceship-prompt zsh-autosuggestions \
        aspnet-runtime-3.1 dotnet-sdk-3.1 aws-cli-v2-bin aws-session-manager-plugin \
        ripgrep docker docker-compose aws-vault pass \
        ncdu glances nnn-nerd mssql-tools jq zoxide-bin lazydocker \
    && sudo pip --disable-pip-version-check install pynvim \
    && sudo npm install -g @angular/cli aws-cdk neovim ng wip \
    && yay -Scc --noprogressbar --noconfirm

RUN git clone https://github.com/Samsung/netcoredbg.git \
    && mkdir netcoredbg/build \
    && cd netcoredbg/build \
    && CC=clang CXX=clang++ cmake .. -GNinja -DDOTNET_DIR=/usr/share/dotnet -DCMAKE_INSTALL_PREFIX=/usr/bin \
    && sudo ninja install \
    && cd ../.. \
    && sudo rm -Rf netcoredbg \
    && yay -S --noprogressbar --noconfirm code-server

RUN git clone https://github.com/neovim/neovim \
    && cd neovim \
    && make CMAKE_BUILD_TYPE=Release \
    && sudo make install \
    && cd .. && sudo rm -Rf neovim 

# I don't know why I have to set this again, but I do...
RUN sudo sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen \
    && sudo locale-gen

# This probably only needs to be run on the host
# RUN echo fs.inotify.max_user_watches=524288 \
#    | sudo tee /etc/sysctl.d/40-max-user-watches.conf \
#      && sudo sysctl --system

# The following lines can be run repeatedly to update everything
# just CACHE_BREAKER to todays date or something similar and rebuild
ARG CACHE_BREAKER=""
RUN yay -Syu --noprogressbar --noconfirm \
    && yay -Scc --noprogressbar --noconfirm

ENV TERM="xterm-256color" \
    PORT=8888

CMD [ "/usr/bin/code-server", "--auth",  "none" ]
