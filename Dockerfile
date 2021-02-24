FROM alpine:latest as builder

WORKDIR /mnt/build/ctags

RUN apk --no-cache add \
	git \
	xfce4-dev-tools \
	build-base

RUN \
	git clone https://github.com/universal-ctags/ctags \
	&& cd ctags \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local \
	&& make \
	&& make install



FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine AS base

ENV \
    UID="1000" \
    GID="1000" \
    UNAME="neovim" \
    GNAME="neovim" \
    SHELL="/bin/bash" \
    WORKSPACE="/mnt/workspace" \
	NVIM_CONFIG="/home/neovim/.config/nvim" \
	NVIM_PCK="/home/neovim/.local/share/nvim/site/pack" \
	ENV_DIR="/home/neovim/.local/share/vendorvenv" \
	NVIM_PROVIDER_PYLIB="python3_neovim_provider" \
	PATH="/home/neovim/.local/bin:${PATH}" \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

COPY --from=builder /usr/local/bin/ctags /usr/local/bin

COPY ./rds-ca-2019-root.crt /usr/local/share/ca-certificates/rds-ca-2019-root.crt

RUN apk update && apk --no-cache add \
		# used to update certificates
	icu-libs \
	curl wget \
	shadow sudo su-exec \
	python3 py3-virtualenv nodejs \
	fzf	zsh zsh-autosuggestions zsh-syntax-highlighting bind-tools \
	# install build packages
	&& apk --no-cache add --virtual build-dependencies \
	python3-dev \
	gcc \
	musl-dev \
	git \
	# create user
	&& addgroup "${GNAME}" \
	&& adduser -D -G "${GNAME}" -g "" -s "${SHELL}" "${UNAME}" \
        && echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	# install neovim python3 provider
	&& sudo -u neovim python3 -m venv "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}" \
	&& "${ENV_DIR}/${NVIM_PROVIDER_PYLIB}/bin/pip" install pynvim \
	&& sudo update-ca-certificates \
	&& /bin/sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" \
	&& echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc \
	&& echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc

RUN /bin/sh -c curl -fLo nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz \
	&& tar -xzf nvim-linux64.tar.gz \
	&& mv nvim-linux64/share/* /usr/local/share/ \
	&& mv nvim-linux64/bin/* /usr/local/bin/ \
	&& mv nvim-linux64/lib/* /usr/local/lib/ \
	&& rm -rf nvim-linux64*

RUN npm install -g @angular/cli aws-cdk neovim ng wip

COPY entrypoint.sh /usr/local/bin/

VOLUME "${WORKSPACE}"
VOLUME "${NVIM_CONFIG}"

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
