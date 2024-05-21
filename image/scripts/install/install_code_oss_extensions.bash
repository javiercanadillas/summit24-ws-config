#!/usr/bin/env bash
# Install VS Code extensions in Linux systems
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

declare -A vsx_ext_list=(
  ["gitgraph"]="https://open-vsx.org/api/mhutchie/git-graph/1.30.0/file/mhutchie.git-graph-1.30.0.vsix"
  ["docker"]="https://open-vsx.org/api/ms-azuretools/vscode-docker/1.26.1/file/ms-azuretools.vscode-docker-1.26.1.vsix"
  ["terraform"]="https://open-vsx.org/api/hashicorp/terraform/linux-x64/2.25.2/file/hashicorp.terraform-2.25.2@linux-x64.vsix"
  ["hcl"]="https://open-vsx.org/api/hashicorp/hcl/0.3.2/file/hashicorp.hcl-0.3.2.vsix"
  ["shellcheck"]="https://openvsxorg.blob.core.windows.net/resources/timonwong/shellcheck/linux-x64/0.34.0/timonwong.shellcheck-0.34.0@linux-x64.vsix"
  ["shell-format"]="https://open-vsx.org/api/foxundermoon/shell-format/7.0.1/file/foxundermoon.shell-format-7.0.1.vsix"
  ["go"]=["https://open-vsx.org/api/golang/Go/0.39.1/file/golang.Go-0.39.1.vsix"]
  ["ms-python"]="https://open-vsx.org/api/ms-python/python/2023.20.0/file/ms-python.python-2023.20.0.vsix"
  #["ruff"]="https://open-vsx.org/api/charliermarsh/ruff/linux-x64/2023.38.0/file/charliermarsh.ruff-2023.38.0@linux-x64.vsix"
  #["material-theme"]="https://open-vsx.org/api/zhuangtongfa/material-theme/3.16.0/file/zhuangtongfa.material-theme-3.16.0.vsix"
  #["material-icon-theme"]="https://open-vsx.org/api/PKief/material-icon-theme/4.30.1/file/PKief.material-icon-theme-4.30.1.vsix"
)

# Format is https://{publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/{publisher}/extension/{package}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
# See: https://gist.github.com/taylor-jones/78d4db0163bb0ae94131f58c75f425fe
declare -A vscode_ext_list=(
  ["copilot"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
  ["copilot-chat"]="https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot-chat/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
)

check_debian_like() {
  grep -E -q 'ID=debian|ID=ubuntu' /etc/os-release || {
    echo "This script only works for Debian-based Linux distributions"
    exit 1
  }
}

install_vsx_ext_old() {
  local -r ext_install_dir="$1" && shift
  for vsx_ext_name in "${!vsx_ext_list[@]}"; do
    pushd "$(mktemp -d)" || exit 1
    local vsx_ext_url="${vsx_ext_list[$vsx_ext_name]}"
    local vsx_ext_file="${vsx_ext_url##*/}"
    hash curl || apt-get install -y curl # Get curl if not installed
    if [[ ! -f "$vsx_ext_file" ]]; then
      echo "Installing $vsx_ext_name..."
      curl -OL "$vsx_ext_url" \
        && unzip "$vsx_ext_file" \
        && mv extension "$ext_install_dir/$vsx_ext_name" \
        && rm "$vsx_ext_file"
    fi
    popd || exit 1
  done
}

install_vsx_ext() {
  echo "Installing CodeOSS extensions..."
  for vsx_ext_name in "${!vsx_ext_list[@]}"; do
    echo "Installing $vsx_ext_name..."
    code-oss-cloud-workstations --install-extensions "$vsx_ext_name"  
  done
}

install_vscode_ext() {
  local -r ext_install_dir="$1" && shift``
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
  local -r ext_install_dir="/opt/code-oss/extensions"
  #install_vsx_ext "$ext_install_dir"
  install_vsx_ext "$ext_install_dir"
  #install_vscode_ext "$ext_install_dir"
}

main "$@"