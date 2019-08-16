# Setup
provider "google" {
  project = "lehmann-tech"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

provider "google-beta" {
  project = "lehmann-tech"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

# Common/global resources

resource "google_compute_ssl_policy" "ssl_policy" {
  name            = "ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_dns_managed_zone" "dns_zone_lehmann_tech" {
  name = "lehmann-tech"
  dns_name = "lehmann.tech."
}

resource "google_dns_record_set" "dns_record_set_lehmann_tech" {
  name = "staging.${google_dns_managed_zone.dns_zone_lehmann_tech.dns_name}"
  managed_zone = "${google_dns_managed_zone.dns_zone_lehmann_tech.name}"
  type = "A"
  ttl = 300 # seconds

  rrdatas = [
    "${google_compute_global_address.ip_address_staging.address}"
  ]
}

resource "google_compute_global_address" "ip_address_dev" {
  name = "dev"
}

resource "google_compute_global_address" "ip_address_staging" {
  name = "staging"
}

resource "google_dns_managed_zone" "dns_zone_unwanted_fun" {
  name = "unwanted-fun"
  dns_name = "unwanted.fun."
}

resource "google_dns_record_set" "dns_record_set_unwanted_fun_dev" {
  name = "dev.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"
  managed_zone = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  type = "A"
  ttl = 300 # seconds = 5 minutes

  rrdatas = [
    "${google_compute_global_address.ip_address_dev.address}"
  ]
}

resource "google_dns_record_set" "dns_record_set_unwanted_fun_staging" {
  name = "staging.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"
  managed_zone = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  type = "A"
  ttl = 300 # seconds = 5 minutes

  rrdatas = [
    "${google_compute_global_address.ip_address_staging.address}"
  ]
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

# dev environment

# Note: KeyRings cannot be deleted from Google Cloud Platform.
# Destroying a Terraform-managed KeyRing will remove it from state
# but will not delete the resource on the server.
# https://www.terraform.io/docs/providers/google/r/kms_key_ring.html
resource "google_kms_key_ring" "kms_keyring_dev" {
  name     = "dev"
  location = "europe-west1"
}

resource "google_kms_crypto_key" "kms_crypto_key_etcd_database_encryption_password_dev" {
  name     = "etcd-database-encryption-password"
  key_ring = "${google_kms_key_ring.kms_keyring_dev.self_link}"
}

resource "google_compute_network" "vpc_network_dev" {
  name                    = "dev"
  auto_create_subnetworks = "true"
}

data "google_container_engine_versions" "container_engine_versions_dev" {
  version_prefix = "1.13."
}

resource "google_container_cluster" "dev_container_cluster" {
  provider = "google-beta"

  name     = "dev"
  location = "europe-west1"
  min_master_version = "${data.google_container_engine_versions.container_engine_versions_dev.latest_master_version}"

  network = "${google_compute_network.vpc_network_dev.self_link}"

  database_encryption {
    state    = "ENCRYPTED"
    key_name = "${google_kms_crypto_key.kms_crypto_key_etcd_database_encryption_password_dev.self_link}"
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

resource "google_container_node_pool" "dev_container_node_pool" {
  name       = "dev-node-pool"
  location   = "europe-west1"
  cluster    = "${google_container_cluster.dev_container_cluster.name}"
  node_count = 2

  version = "${data.google_container_engine_versions.container_engine_versions_dev.latest_master_version}"

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

# staging environment

# Note: KeyRings cannot be deleted from Google Cloud Platform.
# Destroying a Terraform-managed KeyRing will remove it from state
# but will not delete the resource on the server.
# https://www.terraform.io/docs/providers/google/r/kms_key_ring.html
resource "google_kms_key_ring" "kms_keyring_staging" {
  name     = "staging"
  location = "europe-west1"
}

resource "google_kms_crypto_key" "kms_crypto_key_etcd_database_password_staging" {
  name     = "etcd-database-password"
  key_ring = "${google_kms_key_ring.kms_keyring_staging.self_link}"
}

resource "google_compute_network" "staging_vpc_network" {
  name                    = "staging"
  auto_create_subnetworks = "true"
}

data "google_container_engine_versions" "container_engine_versions_staging" {
  version_prefix = "1.13."
}

resource "google_container_cluster" "staging_container_cluster" {
  provider = "google-beta"

  name     = "staging"
  location = "europe-west1"
  min_master_version = "${data.google_container_engine_versions.container_engine_versions_staging.latest_master_version}"

  network = "${google_compute_network.staging_vpc_network.self_link}"

  database_encryption {
    state    = "ENCRYPTED"
    key_name = "${google_kms_crypto_key.kms_crypto_key_etcd_database_password_staging.self_link}"
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

resource "google_container_node_pool" "staging_container_node_pool" {
  name       = "staging-node-pool"
  location   = "europe-west1"
  cluster    = "${google_container_cluster.staging_container_cluster.name}"
  node_count = 2

  version = "${data.google_container_engine_versions.container_engine_versions_staging.latest_master_version}"

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
