#!/bin/bash

set -ue

pushd $(dirname ${BASH_SOURCE:-$0})

sudo apt-get update -y
sudo apt-get install -y bison ncurses-dev pkg-config

function install_zsh() {
    if ! command -v mise >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zsh
        echo -e "\e[36mInstalled zsh\e[m\n"
    fi
}

function install_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        curl https://mise.run | sh
        echo -e "\e[36mInstalled mise\e[m\n"
    fi
}

install_zsh
# install_yacc
install_mise

ln -snfv $(pwd)/.config/mise $HOME/.config/mise
ln -snfv $(pwd)/.config/sheldon $HOME/.config/sheldon
ln -snfv $(pwd)/.zshrc $HOME/.zshrc

mise install

popd
