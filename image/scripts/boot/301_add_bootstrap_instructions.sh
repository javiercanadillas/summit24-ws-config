#!/usr/bin/env bash
# File:         301_add_bootstrap_instructions.sh
# Description:  Adds a README.md file with instructions on how to bootstrap the Cloud Workstation
#
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         May 2024
# Version:      1.0

user_name="user"
group_name="user"
readme_file="README.md"
config_dir="/root/.config/configure"

check_readme_file() {
  if [[ ! -f "${config_dir}/${readme_file}" ]]; then
    echo "No README file found in $config_dir, aborting..."
    exit 1
  fi
}

copy_readme_file() {
  cp -- "/root/${readme_file}" "${HOME}/${readme_file}"
  chown "${user_name}:${group_name}" "${HOME}/${readme_file}"
  chmod 644 "${HOME}/${readme_file}"
}

main() {
  copy_readme_file
}

main "$@"