#!/usr/bin/env bash
# File:         301_add_bootstrap_instructions.sh
# Description:  Adds a README.md file with instructions on how to bootstrap the Cloud Workstation
#
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         May 2024
# Version:      1.0

user_name="user"
group_name="user"
source_dir="/root/.config/configure"
readme_file="README.md"

dest_dir="/home/${user_name}"

check_readme_file() {
  if [[ ! -f "${source_dir}/${readme_file}" ]]; then
    echo "No README file found in /root, aborting..."
    exit 1
  fi
}

copy_readme_file() {
  cp -- "${source_dir}/${readme_file}" "${dest_dir}/${readme_file}" && {
    chown "${user_name}:${group_name}" "${dest_dir}/${readme_file}"
    chmod 644 "${dest_dir}/${readme_file}"
    rm -- "${source_dir}/${readme_file}"
  }
}

main() {
  check_readme_file
  copy_readme_file
}

main "$@"