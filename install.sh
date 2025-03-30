#!/bin/bash

set -ue

pushd $(dirname ${BASH_SOURCE:-$0})

# TODO: test: install nix /w nix-installer
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#without-systemd-linux-only
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

# TODO: link config files /w home-manager

ln -snfv $(pwd)/.config/sheldon $HOME/.config/sheldon
ln -snfv $(pwd)/.zshrc $HOME/.zshrc
ln -snfv $(pwd)/.config/zsh $HOME/.config/zsh
ln -snfv $(pwd)/.ripgreprc $HOME/.ripgreprc
ln -snfv $(pwd)/.config/systemd $HOME/.config/systemd
ln -snfv $(pwd)/.gitconfig $HOME/.gitconfig

popd
