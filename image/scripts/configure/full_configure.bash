#!/usr/bin/env bash
## Prevent this script from being sourced
#shellcheck disable=SC2317
return 0 2>/dev/null || :

set -uoex pipefail

_pathmunge() {
  if ! echo "$PATH" | /bin/grep -E -q "(^|:)$1($|:)"; then
    if [ "$2" = "after" ]; then
      PATH="$PATH:$1"
    else
      PATH="$1:$PATH"
    fi
  fi
}

set_timezone() {
  echo "Setting timezone..."
  local -r TZ="Europe/Madrid"
  ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" >/etc/timezone
}

set_system_wide_aliases() {
  echo "Setting system-wide aliases..."
  cat <<'EOF' >>"/etc/bash.bashrc"
# System-wide aliases
alias code='code-oss-cloud-workstations'
alias bat='batcat'
alias tf='terraform'
alias k='kubectl'
alias gauth='gcloud auth login'
alias gproj='gcloud config set project'
alias gconf='gcloud config configurations'

# System-wide functions
_pathmunge() {
  if ! echo "$PATH" | /bin/grep -E -q "(^|:)$1($|:)"; then
    if [ "$2" = "after" ]; then
      PATH="$PATH:$1"
    else
      PATH="$1:$PATH"
    fi
  fi

_add_line_if_not_exists() {
  local file="$1"
  local line="$2"
  if ! grep -Fxq "$line" "$file"; then
    echo "$line" >>"$file"
  fi
}

EOF
}

set_system_wide_path() {
  echo "Setting system-wide PATH..."
  # Nothing to add here for the moment
}

main() {
  set_timezone
  set_system_wide_aliases
  #set_system_wide_path
}

main "$@"
