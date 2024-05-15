#!/usr/bin/env bash
# File:         update_config.bash
# Description:  Updates a GCP Cloud Workstation configuration based on a new
#               container image URL
#
# Usage:        this script is to be invoked by a Cloud Build Pipeline. It
#               expects the following environment variables to be set:
#                 - CW_CONFIG_NAME: the name of the Cloud Workstation config to
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         November 2023
# Version:      1.0

#set -eox pipefail
set -xo pipefail

persistence_file="${PERSISTENCE_FILE:=vars.env}"
workspace="${WORKSPACE_DIR:=.}"
persistence_file_path="${workspace}/${persistence_file}"

# Check that the persistence file exists, required to load the IMAGE_URL
check_persistence_file() {
  echo "Checking persistence file..."
  [[ -f  $persistence_file_path ]] || {
    echo "Can't load file: \$persistence_file not found"
    exit 1
  }
}

# Check that the required variables are set
check_vars() {
  echo "Checking required variables..."
  [[ -z $CW_CONFIG_NAME ]] && {
    echo "Can't get Cloud Workstation Configuration Name: \$CW_CONFIG_NAME not defined"
    exit 1
  }

  [[ -z $GCP_REGION ]] && {
    echo "Can't get GCP_REGION, you need to pass one."
    exit 1
  }
  echo "All required variables are set."
}

# Load a variable from the persistence file
# Usage: load_var <var_name>
# Returns: the value of the variable
# DO NOT USE ECHO OTHER THAN TO RETURN THE VALUE
load_var() {
  local -r var_name="$1" && shift
  var_value="$(grep "$var_name" "${persistence_file_path}" | cut -d '=' -f2-)" || {
    echo "Can't load variable $var_name from persistence file" && exit 1
  }
  echo "$var_value"
}

# Update the Cloud Workstation configuration with the new image URL
update_config() {
  echo "Updating Cloud Workstation config with image URL $image_url..."
  gcloud beta workstations configs update "$CW_CONFIG_NAME" \
    --cluster="$CW_CLUSTER_NAME" \
    --region="$GCP_REGION" \
    --container-custom-image="$image_url" || {
      echo "Can't update Cloud Workstation configuration."
      exit 1
    }
}


main() {
  check_persistence_file
  check_vars
  echo "Loading image URL variable..."
  image_url=$(load_var "IMAGE_URL") || {
    echo "Can't load variable IMAGE_URL into image_url variable."
    exit 1
  }
  # The following is not required if the configuration
  # is configured to pick up the latest tag
  update_config
}

main "$@"