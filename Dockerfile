FROM archlinux:base-devel

WORKDIR /mnt/build/ctags

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="neovim" \
    GNAME="neovim" \
    SHELL="/bin/zsh" \
    WORKSPACE="/mnt/workspace" \
	NVIM_CONFIG="/home/neovim/.config/nvim" \
	NVIM_PCK="/home/neovim/.local/share/nvim/site/pack" \
	ENV_DIR="/home/neovim/.local/share/vendorvenv" \
	NVIM_PROVIDER_PYLIB="python3_neovim_provider" \
	PATH="/home/neovim/.local/bin:${PATH}" \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

RUN groupadd "${GNAME}" \
	&& useradd -D -G "${GNAME}" -g "${GNAME}" -s "${SHELL}" "${UNAME}" \
    && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& cd /home/neovim

RUN sudo pacman -Syu \
	&& sudo pacman -S git \
	&& git clone https://aur.archlinux.org/yay.git \
	&& cd yay \
	&& makepkg -si

COPY ./rds-ca-2019-root.crt /usr/local/share/ca-certificates/rds-ca-2019-root.crt

RUN update-ca-certificates \
	&& sudo -u neovim python3 -m venv "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}" \
	&& "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip" --disable-pip-version-check install pynvim \
	&& /bin/sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
	&& echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
	&& echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc \
	&& curl -fLo nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz \
	&& tar -xzf nvim-linux64.tar.gz \
	&& mv nvim-linux64/share/* /usr/local/share/ \
	&& mv nvim-linux64/bin/* /usr/local/bin/ \
	&& mv nvim-linux64/lib/* /usr/local/lib/ \
	&& rm -rf nvim-linux64* \
	&& npm install -g @angular/cli aws-cdk neovim ng wip

COPY entrypoint.sh /usr/local/bin/

VOLUME "${WORKSPACE}"
VOLUME "${NVIM_CONFIG}"

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
