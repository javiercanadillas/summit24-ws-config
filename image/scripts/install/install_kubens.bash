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

__install_kubens_script() {
  pushd "$(mktemp -d)" || exit 1
  curl -LO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -o kubens
  install kubens /usr/local/bin
  popd || exit 1
}

check_os_and_install() {
  case "$(uname)" in
    "Darwin")
      echo "Installing kubens for Mac..."
      __install_kubens_script
      ;;
    "Linux")
      echo "Installing kubens for Linux..."
      __install_kubens_script
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