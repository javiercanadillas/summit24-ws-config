locals {
  ar_repo_name = "${var.ws_id}-images"
  image_registry_url = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${local.ar_repo_name}"
  ws_image_name = "${var.ws_id}-image"
  ws_config_id = "${var.ws_id}-config"
}

# Service Accounts and IAM permissions for the workstation runner
resource "google_service_account" "ws_runner" {
  account_id   = "${var.ws_id}-runner-sa"
  display_name = "Service Account for workstation ${var.ws_id}"
}

resource "google_project_iam_member" "ws_runner"{
  project = var.gcp_project_id
  role = [
    "roles/artifactregistry.reader",      # Read the custom cw container image
    "roles/iap.tunnelResourceAccessor",   # Grant SSH access to other GCE machines
  ]
  member = "serviceAccount:google_service_account.ws_runner.email"
}

# Workstation image automation resources
resource "google_sourcerepo_repository" "ws_image_repo" {
  name     = var.ws_id
  project  = var.gcp_project_id
}

resource "google_service_account" "cb_builder" {
  account_id   = "${var.ws_id}-cb-sa"
  display_name = "Service Account for Cloud Build workstation building pipeline"
}

resource "google_project_iam_member" "cb_builder"{
  project = var.gcp_project_id
  role = [
    "roles/storage.admin",                
    "roles/artifactregistry.admin",
    "roles/storage.objectUser",
    "roles/logging.logWriter"
  ]
  member = "serviceAccount:google_service_account.cb_builder.email"
}

resource "google_artifact_registry_repository" "custom_ws_images" {
  provider      = google-beta
  location      = var.gcp_region
  repository_id = local.ar_repo_name
  description   = "Custom Cloud Workstations images"
  format        = "DOCKER"
  project       = var.gcp_project_id
}

resource "google_cloudbuild_trigger" "trigger" {
  provider = google-beta
  project  = var.gcp_project_id
  name     = "${var.ws_id}-trigger"
  description = "Trigger for custom-cw-images"
  
  trigger_template {
    repo_name   = var.ws_id
    branch_name = "main"
  }

  substitutions = {
    _CW_CONFIG_NAME = local.ws_config_id
    _ARTIFACT_REGISTRY_BASE_URL = local.image_registry_url
    _IMAGE_NAME = local.ws_image_name
  }

  filename = "cloudbuild.yaml"

  service_account = google_service_account.cb_builder.email
}

# Networking resources (optional activation based on the custom_network variable)
resource "google_compute_network" "custom" {
  name                    = "workstation-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom" {
  network       = google_compute_network.custom.name
  name          = "workstation-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region
}

# Workstation resources
resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  workstation_cluster_id = var.ws_cluster_id
  network                = var.custom_network ? google_compute_network.custom.id : "default"
  subnetwork             = var.custom_network ? google_compute_subnetwork.custom.id : "default"
  location               = var.gcp_region
}

resource "google_workstations_workstation_config" "ws_config" {
  provider                = google-beta
  workstation_config_id   = local.ws_config_id
  workstation_cluster_id  = var.ws_cluster_id
  location                = var.gcp_region
  idle_timeout            = local.ws_config["idle_timeout"]
  running_timeout         = local.ws_config["running_timeout"]

  host {
    gce_instance {
      machine_type                = var.machine["type"]
      boot_disk_size_gb           = var.machine["boot_disk_size_gb"]  
      disable_public_ip_addresses = var.machine["disable_public_ip_addresses"]
      pool_size                   = var.machine["pool_size"]
      service_account             = google_service_account.ws_runner.email
    }
  }

  container {
    image = "${local.image_registry_url}/${local.ws_image_name}:latest"
  }

  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = 200
      fs_type        = "ext4"
      disk_type      = "pd-standard"
      reclaim_policy = "RETAIN"
    }
  }
}

resource "google_workstations_workstation" "custom" {
  provider                = google-beta
  workstation_id          = var.ws_id
  workstation_config_id   = var.ws_config["name"]
  workstation_cluster_id  = var.ws_cluster_id
  location                = var.gcp_region
}

resource "google_workstations_workstation_iam_member" "member" {
  provider = google-beta
  project = var.gcp_project_id
  location = var.gcp_region
  workstation_cluster_id = google_workstations_workstation.custom.workstation_cluster_id
  workstation_config_id = google_workstations_workstation.custom.workstation_config_id
  workstation_id = google_workstations_workstation.custom.workstation_id
  role = "roles/workstations.user"
  member = "user:${var.user_email}"
}

resource "google_project_iam_member" "ws_user"{
  project = var.gcp_project_id
  role = "roles/workstations.operationViewer"
  member = "user:${var.user_email}"
}