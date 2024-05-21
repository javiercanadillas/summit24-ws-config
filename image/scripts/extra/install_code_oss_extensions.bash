#!/usr/bin/env bash
# Install VS Code extensions in Code OSS for Linux systems as end user
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

# Decide if you want to install non OSS extensions
INSTALL_MS_EXTS=false

declare -a vsx_ext_list=(
  "gitgraph"
  "docker"
  "terraform"
  "hcl"
  "shellcheck"
  "shell-format"
  "go"
  "ms-python"
  "ruff"
  "material-theme"
  "material-icon-theme"
)

# Detect sudo
check_sudo() {
  if [[ $EUID -eq 0 ]]; then
     echo "This script must not be run as root. Please run it as a regular user." 
     exit 1
  fi
}

# Format is https://{publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/{publisher}/extension/{package}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
# See: https://gist.github.com/taylor-jones/78d4db0163bb0ae94131f58c75f425fe
declare -A vscode_ext_list=(
  ["copilot"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
  ["copilot-chat"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot-chat/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
)

# Installs Code OSS extensions from the Open VSXI Marketplace using the cli
install_vsx_exts() {
  local vsx_ext_name
  for vsx_ext_name in "${vsx_ext_list[@]}"; do
    code-oss-cloud-workstations --install-extension "$vsx_ext_name"
  done
}

# Installs VSCode Extensions from Microsoft's Marketplace
install_dl_vscode_exts() {
  local -r ext_install_dir="$1" && shift
  local vscode_ext_name
  for vscode_ext_name in "${!vscode_ext_list[@]}"; do
    pushd "$(mktemp -d)" || exit 1
    local vscode_ext_url="${vscode_ext_list[$vscode_ext_name]}"
    local vscode_ext_file="${vscode_ext_name}.zip"
    hash curl || apt-get install -y curl # Get curl if not installed
    if [[ ! -f "$vscode_ext_file" ]]; then
      echo "Installing $vscode_ext_name..."
      curl "$vscode_ext_url" -o "${vscode_ext_file}" \
        && unzip "${vscode_ext_file}" \
        && mv extension "$ext_install_dir/$vscode_ext_name" \
        && rm "$vscode_ext_file"
    fi
    popd || exit 1
  done
}

main() {
  check_sudo
  local -r ext_install_dir="$HOME/.code-oss-workstation/extensions"
  install_vsx_exts
  # These extensions don't belong to the VSXI marketplace, so installing them
  # by downloading the corresponding package from Microsoft
  [[ "$INSTALL_MS_EXTS" == true ]] && install_dl_vscode_exts "$ext_install_dir"
}

main "$@"