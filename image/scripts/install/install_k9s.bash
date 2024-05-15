#!/usr/bin/env bash
# Install K9s in Linux systems
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

install_binary() {
  local -r temp_dir="$(mktemp -d)"
  pushd "$temp_dir" || exit 1
  curl -L -o- https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz | \
    tar -xvzf - | \
    install /dev/stdin  /usr/local/bin/k9s
  popd || exit 1
  rm -rf -- "$temp_dir"
}

main() {
  check_linux
  install_binary
}

main "$@"