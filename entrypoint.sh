#!/usr/bin/env sh

usermod -u "${UID}" neovim
groupmod -g "${GID}" neovim
# su-exec neovim nvim +UpdateRemotePlugins +qa
cd "${WORKSPACE}" && su-exec neovim nvim "$@"
# su-exec neovim sh
