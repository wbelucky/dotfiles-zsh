# dotfiles

## install nix

```shell
# core dependencies
#sudo apt install curl ca-certificates xz-utils

# multi-user installs
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# single-user installs (like containers)
sh <(curl -L [Not Found | Nix & NixOS](https://nixos.org/nix/install)) --no-daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

## test

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
./install.sh
```

nix

```sh
nix run home-manager/master -- switch --flake .#opteyo -b backup
# sudo su

# nix profile install .#dotfiles-zsh
```

## debug

```
(builtins.trace ''neovim ${neovim}'' neovim)
```

