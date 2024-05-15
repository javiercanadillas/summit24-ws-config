#!/usr/bin/env bash
# Install or update Nix on Linux systems
# See https://nixos.org/manual/nix/stable/installation/installing-binary
# 2024 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

# Performs a multi-user installation of Nix
install_nix() {
  local -r temp_dir="$(mktemp -d)"
  pushd "$temp_dir" || exit 1
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
  popd || exit 1
  rm -rf -- "$temp_dir"
}

main() {
  check_linux
  install_nix
}

main "$@"