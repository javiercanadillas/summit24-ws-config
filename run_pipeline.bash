#!/usr/bin/env bash
# File:         run_pipeline.bash
# Description:  Runs a Cloud Build Pipeline to build and push the custom
#               workstation Docker image.
#
# Usage:        ./run_pipeline.bash
# Author:       Javier Cañadillas (javier@canadillas.org)
# Date:         November 2023
# Version:      1.0

set -eou pipefail

set_vars() {
  ar_base_url="${IMAGE_REGISTRY_URL:-"europe-west1-docker.pkg.dev/javiercm-main-dev/custom-cw-images"}"
  image_name="${WS_IMAGE_NAME:-"custom-ws-image"}"
  cw_config_name="${WS_CONFIG_NAME:-"custom-config"}"
  cw_cluster_name="${WS_CLUSTER_NAME:-"main-cluster"}"
}

run_pipeline() {
  gcloud beta builds submit \
    --config ./image/cloudbuild.yaml \
    --substitutions=_ARTIFACT_REGISTRY_BASE_URL="$ar_base_url",_IMAGE_NAME="$image_name",_CW_CONFIG_NAME="$cw_config_name",_CW_CLUSTER_NAME="$cw_cluster_name",_GCP_REGION="europe-west1" \
    --service-account="projects/javiercm-main-dev/serviceAccounts/custom-cw-cb-sa@javiercm-main-dev.iam.gserviceaccount.com" \
    --region="europe-west1"
}

main() {
  set_vars
  run_pipeline
}

main "$@"