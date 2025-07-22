#!/bin/bash

set -ue

pushd $(dirname ${BASH_SOURCE:-$0})

curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
./scripts/update
./scripts/switch

# TODO: test: install nix /w nix-installer
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#without-systemd-linux-only
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
#   --extra-conf "sandbox = false" \
#   --init none \
#   --no-confirm

popd
