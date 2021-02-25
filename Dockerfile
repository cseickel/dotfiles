FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    SHELL="/bin/zsh" \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

COPY ./rds-ca-2019-root.crt /usr/share/ca-certificates/trust-source/rds-ca-2019-root.crt

RUN pacman -Syu --noprogressbar --noconfirm --needed \
	   git zsh python3 python-pip nodejs npm wget curl \
	&& update-ca-trust \
	&& useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER arch

RUN cd /home/$UNAME \
	&& git clone https://aur.archlinux.org/yay.git \
	&& cd yay \
	&& makepkg -si --noprogressbar --noconfirm

RUN yay -S --noprogressbar --noconfirm \
	   neovim-nightly-bin neovim-plug oh-my-zsh-git spaceship-prompt \
	   aspnet-runtime-3.1 dotnet-sdk-3.1 \
	&& sudo pip --disable-pip-version-check install pynvim \
	&& sudo npm install -g @angular/cli aws-cdk neovim ng wip \
	&& yay -Sc --noprogressbar --noconfirm

RUN mkdir -p ~/.config/nvim/colors \
	&& cd /home/$UNAME \
	&& git --global config pull.ff only
	&& git clone https://github.com/cseickel/dotfiles.git .dotfiles \
	&& /bin/sh /home/$UNAME/.dotfiles/install \
	&& nvim +PlugInstall +qa
