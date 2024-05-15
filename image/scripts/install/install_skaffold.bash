#!/usr/bin/env bash
# Install Terraform in Linux systems
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

install_package() {
  curl -L -o - https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && gpg --no-default-keyring \
      --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
      --fingerprint \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list \
  && apt-get -y update \
  && apt-get -y install terraform
}

main() {
  check_linux
  install_package
}

main "$@"