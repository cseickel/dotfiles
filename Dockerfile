FROM archlinux:base-devel

WORKDIR /mnt/build/ctags

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="arch" \
    GNAME="arch" \
    SHELL="/bin/zsh" \
    WORKSPACE="/mnt/workspace" \
	NVIM_CONFIG="/home/arch/.config/nvim" \
	NVIM_PCK="/home/arch/.local/share/nvim/site/pack" \
	ENV_DIR="/home/arch/.local/share/vendorvenv" \
	NVIM_PROVIDER_PYLIB="python3_neovim_provider" \
	PATH="/home/arch/.local/bin:${PATH}" \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

COPY ./rds-ca-2019-root.crt /usr/share/ca-certificates/trust-source/rds-ca-2019-root.crt

RUN pacman -Syu --noprogressbar --noconfirm \
	&& pacman -S --noprogressbar --noconfirm \
	   git zsh ca-certificates-utils \
	&& update-ca-trust \
	&& useradd -m -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER arch

RUN cd /home/arch \
	&& git clone https://aur.archlinux.org/yay.git \
	&& cd yay \
	&& makepkg -si --noprogressbar --noconfirm \
	&& python3 -m venv "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}" \
	&& "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip" --disable-pip-version-check install pynvim \
	&& /bin/sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
	&& echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
	&& echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc \
	&& curl -fLo nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz \
	&& tar -xzf nvim-linux64.tar.gz \
	&& sudo mv nvim-linux64/share/* /usr/local/share/ \
	&& sudo mv nvim-linux64/bin/* /usr/local/bin/ \
	&& sudo mv nvim-linux64/lib/* /usr/local/lib/ \
	&& rm -rf nvim-linux64* \
	&& npm install -g @angular/cli aws-cdk neovim ng wip

COPY entrypoint.sh /usr/local/bin/

VOLUME "${WORKSPACE}"
VOLUME "${NVIM_CONFIG}"

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
