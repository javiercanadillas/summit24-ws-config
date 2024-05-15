#!/usr/bin/env bash
# Install VS Code extensions in Code OSS for Linux systems as end user
# 2023 - Javier Cañadillas <javier at canadillas.org>
#todo detect that this script is not being called with sudo or root privileges
#todo detect that a Linux system is present

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

# Format is https://{publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/{publisher}/extension/{package}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
# See: https://gist.github.com/taylor-jones/78d4db0163bb0ae94131f58c75f425fe
declare -A vscode_ext_list=(
  ["copilot"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
  ["copilot-chat"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot-chat/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
)

# Installs Code OSS extensions from the Open VSXI Marketplace using the cli
#todo I should pass the extensions list to this function
install_vsx_exts() {
  local vsx_ext_name
  for vsx_ext_name in "${vsx_ext_list[@]}"; do
    #todo check that code alias exists and if not, solve the issue
    code --install-extension "$vsx_ext_name"
  done
}

# Installs VSCode Extensions from Microsoft's Marketplace
#todo I should pass the extensions list to this function
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
  check_debian_like
  #todo check that the directory below is correct
  local -r ext_install_dir="$HOME/.code-oss-workstation/extensions"
  install_vsx_exts
  # These extensions don't belong to the VSXI marketplace, so installing them
  # by downloading the corresponding package from Microsoft
  [[ "$INSTALL_MS_EXTS" == false ]] && install_dl_vscode_exts "$ext_install_dir"
}

main "$@"