#!/usr/bin/env bash

## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0  2>/dev/null || :

set -uo pipefail

# shellcheck disable=SC2128
setup_script() {
  script_name=$(basename "$BASH_SOURCE")
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  reset=$(tput sgr0)
  
  __info() {
    echo "${green}${script_name}${reset}: ${1}" >&2
  }

  __error() {
    echo "${red}${script_name}${reset}: ${1}" >&2
  }

  __eecho() {
    local -r message=$1 && shift
    padding="$(printf '%*s' "${#script_name}" "")"
    echo "${padding}  ${message}" >&2
  }

  __check_command() {
    local -r cmd="$1" && shift
    hash "${cmd}" || {
      __error "Command not found: ${cmd}"
      exit 1
    }
  }
}

__install_shellcheck_linux() {
  local -r temp_dir="$(mktemp -d)"
  pushd "$temp_dir" || exit 1
  curl -LO https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz | \
    tar -xvzf - | \
    install /dev/stdin  /usr/local/bin/shellcheck
  popd || exit 1
  rm -rf -- "$temp_dir"
}

check_os_and_install() {
  case "$(uname)" in
    "Darwin")
      echo "Not implemented, skipping..."
      ;;
    "Linux")
      echo "Installing kubectx for Linux..."
      __install_shellcheck_linux
      ;;
    *)
      echo "Unknown OS, this script is only supported on Mac and Linux."
      ;;
  esac
}

main() {
  setup_script
  check_os_and_install
}

main "$@"