#!/usr/bin/env bash
# File:         tag_image.bash
# Description:  Tags an existing Artifact Registry Docker image with latest
#
# Usage:        this script is to be invoked by a Cloud Build Pipeline. It
#               expects a persistence_file containing the IMAGE URL to be present.
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         November 2023
# Version:      1.0

set -eox pipefail

persistence_file="${PERSISTENCE_FILE:=vars.env}"
workspace="${WORKSPACE_DIR:=.}"
persistence_file_path="${workspace}/${persistence_file}"

# Check that the persistence file exists, required to load the IMAGE_URL
check_persistence_file() {
  [[ -f  $persistence_file_path ]] || {
    echo "Can't load file: \$persistence_file not found"
    exit 1
  }
}

# Load a variable from the persistence file
# Usage: load_var <var_name>
# Returns: the value of the variable
load_var() {
  local -r var_name="$1" && shift
  var_value="$(grep "$var_name" "${workspace}/${persistence_file}" | cut -d '=' -f2-)"
  echo "$var_value"
}

# Tag an existing Artifact Registry Docker image with latest
tag_image() {
  local -r image_url="$1" && shift
  local -r image_base_url="${image_url%:*}"
  echo "Tagging image $image_url with latest..."
  gcloud artifacts docker tags add "$image_url" "${image_base_url}:latest"
}

main() {
  check_persistence_file
  image_url="$(load_var "IMAGE_URL")"
  tag_image "$image_url"
}

main "$@"