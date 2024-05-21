#!/usr/bin/env bash
# File:         ws_backup_codeoss_extensions.bash
# Description:  backs up the Code-OSS extensions to a file
#               This is intended as an utility script to be used in Cloud Workstations
# Author:       Javier Cañadillas (javier at canadillas.org)

set -uo pipefail
dest_dir="${HOME}/.config/codeoss-extensions"
dest_file="${dest_dir}/codeoss_extensions.txt"

# Detect sudo
check_sudo() {
  if [[ $EUID -eq 0 ]]; then
     echo "This script must not be run as root. Please run it as a regular user." 
     exit 1
  fi
}

# Backs up Code-OSS extensions to a file
backup_codeoss_extensions() {
  echo "Backing up Code-OSS extensions to $dest_file..."
  mkdir -p "$dest_dir"
  code-oss-cloud-workstations --list-extensions | tail -n +2 | grep -v 'googlecloudtools.cloudcode'| tee "$dest_file" || {
    echo "Error backing up Code-OSS extensions, aborting..."
    exit 1
  }
  echo "...done!"
}

main() {
  check_sudo
  backup_codeoss_extensions
}

main "$@"