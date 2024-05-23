#!/usr/bin/env bash
# File:         setup_git_keys.bash
# Description:  Sets up the GitLab SSH keys for the user
#               This is intended as an utility script to be used in Cloud Workstations
# Author:       Javier Cañadillas (javier at canadillas.org)

set -uo pipefail

export key_file_name="ed25519-gitlab"
export project_id="${PROJECT_ID:-javiercm-main-dev}"

# Detect sudo
check_sudo() {
  if [[ $EUID -eq 0 ]]; then
     echo "This script must not be run as root. Please run it as a regular user." 
     exit 1
  fi
}

# Check gcloud login
check_gcloud_login() {
  hash gcloud || {
    echo "gcloud is not installed, aborting..."
    exit 1
  }
  gcloud auth list --filter=status=ACTIVE --format="value(account)" || {
    echo "gcloud is not logged in, you must run 'gcloud auth login' first"
    exit 1
  }
}

# Create the SSH directory if it does not exist
create_ssh_dir() {
  [[ -d "$HOME/.ssh" ]] || {
    echo "$HOME/.ssh does not exist, creating..."
    mkdir -p "$HOME/.ssh"
  }
}

# Get a secret from GCP Secret Manager
_get_secret() {
  hash gcloud || {
    echo "gcloud is not installed, aborting..."
    exit 1
  }
  local -r secret_name="$1" && shift
  local -r secret_version="${1:-latest}" && shift
  local -r output_file="${1}" && shift

  echo "Getting secret $secret_name and storing it into $output_file..."
  gcloud secrets versions access "$secret_version" \
    --project="$project_id" \
    --secret="$secret_name" > "$output_file" || {
    echo "Failed to get secret $secret_name"
    exit 1
  }
}

# Get the GitLab private key from Secret Manager
# The expected name of the secret is "gitlab-ssh-key-public" for all users
get_gitlab_private_key() {
  echo "Getting GitLab private key..."
  local -r secret_name="gitlab-ssh-key-private"
  local -r output_file="$HOME/.ssh/${key_file_name}"
  _get_secret "$secret_name" "latest" "$output_file"
  chmod 600 "$output_file"
}

# Get the GitLab private key from Secret Manager
# The expected name of the secret is "gitlab-ssh-key-public" for all users
get_gitlab_public_key() {
  echo "Getting GitLab public key..."
  local -r secret_name="gitlab-ssh-key-public"
  local -r output_file="$HOME/.ssh/${key_file_name}.pub"
  _get_secret "$secret_name" "latest" "$output_file"
  chmod 600 "$output_file"
}

# Update the SSH config file with the GitLab.com configuration
create_ssh_config() {
  echo "Creating SSH config file..."
  local -r ssh_config_file="$HOME/.ssh/config"
  cat << EOF >> "${ssh_config_file}"
# GitLab.com
Host gitlab.com
  HostName gitlab.com
  AddKeysToAgent yes
  IdentityFile "$HOME/.ssh/${key_file_name}"
  PreferredAuthentications publickey

EOF
}

main() {
  check_sudo
  check_gcloud_login
  create_ssh_dir
  get_gitlab_private_key
  get_gitlab_public_key
  create_ssh_config
}

main "$@"