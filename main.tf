# Setup
provider "google-beta" {
  project = "lehmann-tech"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

# Test stuff
# resource "google_compute_network" "vpc_network" {
#   name                    = "terraform-network"
#   auto_create_subnetworks = "true"
# }

# resource "google_compute_instance" "vm_instance" {
#   name         = "terraform-instance"
#   machine_type = "f1-micro"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-9"
#     }
#   }

#   network_interface {
#     network = "${google_compute_network.vpc_network.self_link}"
#     access_config {
#     }
#   }
# }

# # dev environment
# resource "google_compute_network" "dev_vpc_network" {
#   name                    = "dev"
#   auto_create_subnetworks = "true"
# }

# resource "google_container_cluster" "dev_container_cluster" {
#   name     = "dev"
#   location = "europe-west1"

#   network = "${google_compute_network.dev_vpc_network.self_link}"

#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count = 1

#   master_auth {
#     username = ""
#     password = ""

#     client_certificate_config {
#       issue_client_certificate = false
#     }
#   }
# }

# resource "google_container_node_pool" "dev_container_node_pool" {
#   name       = "dev-node-pool"
#   location   = "europe-west1"
#   cluster    = "${google_container_cluster.dev_container_cluster.name}"
#   node_count = 2

#   node_config {
#     machine_type = "n1-standard-1"

#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }
