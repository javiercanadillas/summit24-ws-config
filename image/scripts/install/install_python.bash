#!/usr/bin/env bash
# Upgrade system wide Python in Linux systems and fix some CVEs
# 2023 - Javier Cañadillas <javier at canadillas.org>

set -eou pipefail

check_linux() {
  local -r os="$(uname -s)"
  [[ "$os" == "Linux" ]] || {
    echo "Reported OS is $os. This script is only for Linux systems, aborting..."
    exit 1
  }
}

upgrade_system_pip() {
  python -m pip install --upgrade pip # Upgrade pip to latest version
}

fix_cves() {
  python -m pip install urllib3 # Fix CVE-2021-33503
}

main() {
  check_linux
  upgrade_system_pip
  fix_cves
}

main "$@"