#!/usr/bin/env bash
# File:         ws_yadm_full_reset.bash
# Description:  Resets any local dotfile to match the remote yadm repository
#               This is intended as an utility script to be used in Cloud Workstations
# Author:       Javier Cañadillas (javier at canadillas.org)

set -uo pipefail

main() {
  gcloud auth login
  gcloud auth application-default login
  ws_setup_git_keys.bash
  ssh-keyscan -H gitlab.com > ~/.ssh/known_hosts
  yadm clone "$DOTFILES_REPO" --bootstrap -f
  ws_yadm_full_reset.bash
  echo "Plese, now source your .bashrc file to apply the changes"
}

main "$@"