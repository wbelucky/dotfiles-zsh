# dotfiles

## test

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
./install.sh
```

nix

```sh
nix run home-manager/master -- switch --flake . -b backup
# sudo su

# nix profile install .#dotfiles-zsh
```
