variable "cluster_name" {
  type = string
}

variable "cluster_location" {
  type = string
  description = <<EOT
                The location of the cluster and its node pool.
                Specify a region (such as europe-west1) for a regional cluster replicated
                across all that region's zones, or specify a zone (such as europe-west1-b)
                for a zonal cluster with nodes in only one zone.
                EOT
}

variable "dns_zone_name" {
  type = string
}

variable "dns_name" {
  type = string
}

# Note: KeyRings cannot be deleted from Google Cloud Platform.
# Destroying a Terraform-managed KeyRing will remove it from state
# but will not delete the resource on the server.
# https://www.terraform.io/docs/providers/google/r/kms_key_ring.html
resource "google_kms_key_ring" "kms_keyring" {
  name     = var.cluster_name
  location = "europe-west1"
}

resource "google_kms_crypto_key" "kms_crypto_key_etcd_database_encryption_password" {
  name     = "etcd-database-encryption-password"
  key_ring = google_kms_key_ring.kms_keyring.self_link
}

resource "google_compute_global_address" "ip_address" {
  name = var.cluster_name
}

resource "google_dns_record_set" "dns_record_set_unwanted_fun" {
  managed_zone = var.dns_zone_name
  name = var.dns_name
  type = "A"
  ttl = 300 # seconds = 5 minutes

  rrdatas = [
    "${google_compute_global_address.ip_address.address}"
  ]
}

resource "google_compute_network" "vpc_network" {
  name                    = var.cluster_name
  auto_create_subnetworks = "true"
}

data "google_container_engine_versions" "container_engine_versions" {
  version_prefix = "1.13."
}

resource "google_container_cluster" "container_cluster" {
  provider = "google-beta"

  name     = var.cluster_name
  location = var.cluster_location
  min_master_version = data.google_container_engine_versions.container_engine_versions.latest_master_version

  network = google_compute_network.vpc_network.self_link

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.kms_crypto_key_etcd_database_encryption_password.self_link
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "container_node_pool" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.cluster_location
  cluster    = google_container_cluster.container_cluster.name
  node_count = 2

  version = data.google_container_engine_versions.container_engine_versions.latest_master_version

  node_config {
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
