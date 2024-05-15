#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

set -uo pipefail

# This should be done by the dotfiles configuration,
# but it doesn't hurt to make sure the $HOME/go directory
# exists and is owned by the user
setup_go_dir() {
  local -r go_path="/home/user/go"
  if [[ ! -d "$go_path" ]]; then
    echo "Setting up Go..."
    echo "Making sure the $go_path directory exists..."
    mkdir -p "$go_path"
    chown -R user:user "$go_path"
    chmod -R 755 "$go_path"
  else
    echo "Go directory already exists."
  fi
}

# Same here, this should be done by the dotfiles configuration,
# but it doesn't hurt to make sure the Bash prompt is updated
# each time the machine boots
download_bash_prompt() {
  bash_config_dir_base="/home/user/.config"
  bash_config_dir="$bash_config_dir_base/bash"
  echo "Downloading Bash prompt..."
  curl -sSL https://raw.githubusercontent.com/javiercm/qwiklabs-cloudshell-setup/master/.prompt -o "$bash_config_dir/.prompt"
  chmod -R user:user "$bash_config_dir/prompt"
}

main() {
  :
  #setup_go_dir
  #update_bash_prompt
}

main "$@"