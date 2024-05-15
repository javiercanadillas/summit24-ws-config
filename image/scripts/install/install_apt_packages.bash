#!/usr/bin/env bash
# Install apt packages in Debian-based systems
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

set -x

declare -a packages_list_base=(
  apt-utils
  apt-transport-https
  build-essential
  ca-certificates
  cmake
  curl
  gnupg
  jq
  lsb-release
  software-properties-common
  amd64-microcode # as of CVE-2023-20569
)

declare -a packages_list_extended=(
  bash-completion
  docker-compose-plugin
  bat
  yadm
  shellcheck
  git
  gh
  google-cloud-sdk-skaffold
  google-cloud-sdk-cloud-run-proxy
  google-cloud-sdk-log-streaming
)

check_debian_like() {
  grep -E -q 'ID=debian|ID=ubuntu' /etc/os-release || {
    echo "This script only works for Debian-based Linux distributions"
    exit 1
  }
}

install_gh_repo() {
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
}

install_git_core_repo() {
  add-apt-repository ppa:git-core/ppa -y
}

prepare_apt() {
  apt-get update
  apt-get upgrade -y --fix-missing
}

install_apt_pkgs() {
  local -r packages=("$@")
  for pkg in "${packages[@]}"; do
    echo "Installing $pkg"
    apt-get install -y "$pkg"
  done
}

main() {
  check_debian_like
  prepare_apt
  install_apt_pkgs "${packages_list_base[@]}"
  install_git_core_repo
  install_gh_repo
  prepare_apt
  install_apt_pkgs "${packages_list_extended[@]}"
  apt autoremove -y
  apt clean
}

main "$@"