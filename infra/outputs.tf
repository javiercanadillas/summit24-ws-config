output "csr_repo_name" {
  value = google_sourcerepo_repository.ws_image_repo.name
}

output "image_registry_url" {
  value = google_artifact_registry_repository.custom_ws_images.repository_url
}

output "ws_image_name" {
  value = google_artifact_registry_repository.custom_ws_images.name
}

output "ws_config_id" {
  value = google_workstations_workstation_cluster.default.config_id
}