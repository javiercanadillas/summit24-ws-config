#!/usr/bin/env bash
# Runs all install scripts in this directory
# This script only works for Linux systems
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -uoex pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

install_all() {
  # Get this script's directory path
  local -r dir="$(dirname "$(readlink -f "$0")")"

  # Loop over all files that start with "install_"
  for file in "$dir"/install_*; do
    # Check if the file is executable
    if [[ -x "$file" ]]; then
      echo "Running $file installer..."
      "$file"
    else
      echo "Skipping $file (not executable)"
    fi
  done
}

main() {
  check_linux
  install_all
}

main "$@"