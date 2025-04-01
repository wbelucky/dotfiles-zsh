# dotfiles

## test

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
./install.sh
```

nix

```
sudo su
nix profile install .#dotfiles-zsh
```
