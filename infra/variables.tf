variable "gcp_project_id" {
  description = "value of the gcp project id"
}

variable "user_email" {
  description = "value of the user email"  
}

variable "gcp_region" {
  description = "value of the gcp region"
  default =  "europe-west1"
}

variable custom_network {
  type = bool
  description = "Wheter to use a custom network"
  default = false
}

variable "ws_cluster_id" {
  description = "value of the workstation cluster id"
  default =  "ws-cluster"
}

variable "ws_config" {
  type = map(string)
  default = {
    "idle_timeout" = "1800s"
    "running_timeout" = "21600s"
  }
}

variable "machine" {
  type = map(string)
  default = {
    "type" = "e2-standard-4"
    "boot_disk_size_gb" = "50"
    "disable_public_ip_addresses" = "false"
    "pool_size" = "1"
  }
}

variable "ws_id" {
  description = "Name of the Cloud Workstation."
  default = "custom-ws"
}