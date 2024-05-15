#!/usr/bin/env bash
# File:         build_image.bash
# Description:  Builds a Docker image and pushes it to a registry.
#
# Usage:        this script is to be invoked by a Cloud Build Pipeline. It
#               expects the following environment variables to be set:
#                 - REGISTRY_URL: the URL of the registry to push the image to.
#                 - IMAGE_NAME: the name of the image to build.
#                 - WORKSPACE_DIR: the persistence directory for files
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         November 2023
# Version:      1.0

set -eox pipefail

persistence_file="${PERSISTENCE_FILE:=vars.env}"
workspace="${WORKSPACE_DIR:=.}"

# Check that the required variables are set
check_vars() {
  echo "Checking required variables..."
  [[ -z $REGISTRY_URL ]] && {
    echo "Can't build image: \$REGISTRY_URL not defined"
    exit 1
  }

  [[ -z $IMAGE_NAME ]] && {
    echo "Can't build image: \$IMAGE_NAME not defined"
    exit 1
  }

  echo "All required variables are set."
}

# Set the environment variables required for this builder
# This configures the image URL to be pushed to the registry containing the timestamp of the build
set_env() {
  suffix=$(date +%Y%m%d%H%M%S)
  image_base_url="$REGISTRY_URL/$IMAGE_NAME"
  image_url="${image_base_url}:${suffix}"
  echo "Set image URL to: $image_url"
}

# Build the Docker image and push it to the registry
build_push_image() {
  echo "Building image $IMAGE_NAME..."
  docker build . -t "$image_url"
  echo "Pushing image to $image_url..."
  docker push "$image_url"
}

# Persist a variable to a file in the workspace directory
# Usage: persist_var <var_name> <var_value>
persist_var() {
  local -r var_name="$1" && shift
  local -r var_value="$1" && shift
  echo "Persisting variable $var_name..."
  echo "$var_name=$var_value" >> "${workspace}/${persistence_file}"
  cat "${workspace}/${persistence_file}"
}

main() { 
  set_env
  check_vars
  # Persist the image URL to be used by the next step in the pipeline
  persist_var "IMAGE_URL" "$image_url" && echo "Variable IMAGE_URL recorded with value $image_url successfully!"
  build_push_image && echo "Image built successfully!"
}

main "$@"