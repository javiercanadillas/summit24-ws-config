#!/usr/bin/env bash
# File:         ws_yadm_full_reset.bash
# Description:  Resets any local dotfile to match the remote yadm repository
#               This is intended as an utility script to be used in Cloud Workstations
# Author:       Javier Cañadillas (javier at canadillas.org)

set -uo pipefail

# Detect sudo
check_sudo() {
  if [[ $EUID -eq 0 ]]; then
     echo "This script must not be run as root. Please run it as a regular user." 
     exit 1
  fi
}

reset_yadm() {
  echo "Restoring all conflicting files to match the remote yadm repository..."
  pushd "$HOME" || exit 1
  for file in $(yadm diff --name-only); do
    echo "Resetting $file..."
    yadm restore "$file"
  done
  popd || exit 1
}

main() {
  check_sudo
  reset_yadm
}

main "$@"