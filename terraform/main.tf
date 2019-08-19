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

# dev environment

module "dev_environment" {
  source = "./environments"

  cluster_name = "dev"
}

# staging environment

module "staging_environment" {
  source = "./environments"

  cluster_name = "staging"
}
