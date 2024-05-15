#!/usr/bin/env bash

copy_user_settings() {
  echo "Copying user settings..."

  CODEOSS_PATH="/home/user/.codeoss-cloudworkstations"
  SETTINGS_PATH="$CODEOSS_PATH/data/Machine"

  mkdir -p $SETTINGS_PATH

  cat <<EOF >"$SETTINGS_PATH/settings.json"
{
    "workbench.colorTheme": "One Dark Pro Flat",
    "editor.fontSize": 14,
    "interactiveSession.editor.fontSize": 14,
    "terminal.integrated.fontSize": 14,
    "debug.console.fontSize": 14,
    "terminal.integrated.enableMultiLinePasteWarning": false,
    "terminal.integrated.detectLocale": "off",
    "shellcheck.disableVersionCheck": true,
    "shellcheck.customArgs": [
        "-x"
    ]
}
EOF

  chown -R user:user "$CODEOSS_PATH"
  chmod -R 755 "$CODEOSS_PATH"
}

main() {
  :
  #copy_user_settings
}

main "$@"
