#!/usr/bin/env bash
# Install or update Golang in Linux systems
# See https://go.dev/doc/install
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

cleanup_existing() {
  rm -rf -- /usr/local/go
}

install_package() {
  local -r temp_dir="$(mktemp -d)"
  pushd "$temp_dir" || exit 1
  curl -L -o- https://go.dev/dl/go1.21.4.linux-amd64.tar.gz | \
    tar -xvzf - -C /usr/local
  popd || exit 1
  rm -rf -- "$temp_dir"
}

main() {
  check_linux
  cleanup_existing
  install_package
}

main "$@"