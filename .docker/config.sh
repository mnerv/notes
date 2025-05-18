#!/usr/bin/env sh
deps="
bat
build-base
coreutils
curl
exa
git
htop
neovim
neovim-doc
nodejs
openssh
openssl
parallel
ripgrep
shadow
tmux
wget
zsh
"
deps=$(printf "$deps" | tr '\n' ' ' | sed -e 's/^[[:space:]]*//')

apk add --no-cache $deps
