#!/usr/bin/env bash
# File:         301_add_bootstrap_instructions.sh
# Description:  Adds a README.md file with instructions on how to bootstrap the Cloud Workstation
#
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         May 2024
# Version:      1.0

user_name="user"
group_name="user"
source_dir="/root/.configure"
settings_file="settings.json"
dest_dir="/home/${user_name}"

check_settings_file() {
  if [[ ! -f "${source_dir}/${settings_file}" ]]; then
    echo "No $settings_file file found in /root, aborting..."
    exit 1
  fi
}

add_code_oss_machine_settings() {
  cp -- "${source_dir}/${settings_file}" "${dest_dir}/${settings_file}" && {
    chown "${user_name}:${group_name}" "${dest_dir}/${settings_file}"
    chmod 644 "${dest_dir}/${settings_file}"
    rm -- "${source_dir}/${settings_file}"
  }
}

main() {
  add_code_oss_machine_settings
}

main "$@"