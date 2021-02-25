FROM archlinux:base-devel

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    SHELL="/bin/zsh" \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

COPY ./rds-ca-2019-root.crt /usr/share/ca-certificates/trust-source/rds-ca-2019-root.crt

RUN pacman -Syu --noprogressbar --noconfirm \
	&& pacman -S --noprogressbar --noconfirm \
	   git zsh ca-certificates-utils \
	&& update-ca-trust \
	&& useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER arch

RUN cd /home/$UNAME \
	&& git clone https://aur.archlinux.org/yay.git \
	&& cd yay \
	&& makepkg -si --noprogressbar --noconfirm

RUN yay -S --noprogressbar --noconfirm \
	python3 node npm neovim-nightly-bin \
	&& /bin/sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
	&& echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
	&& echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc \
	&& git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm \
	&& sudo pip --disable-pip-version-check install pynvim \
	&& npm install -g @angular/cli aws-cdk neovim ng wip

RUN yay -Sc --noprogressbar --noconfirm
