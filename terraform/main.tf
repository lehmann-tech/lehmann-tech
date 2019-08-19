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

resource "google_dns_managed_zone" "dns_zone_unwanted_fun" {
  name = "unwanted-fun"
  dns_name = "unwanted.fun."
}

# dev environment

module "dev_environment" {
  source = "./environments"

  cluster_name = "dev"
  dns_zone_name = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name = "dev.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"
}

# staging environment

module "staging_environment" {
  source = "./environments"

  cluster_name = "staging"
  dns_zone_name = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name = "staging.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"
}

module "prod_environment" {
  source = "./environments"

  cluster_name = "prod"
  dns_zone_name = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name = "${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"
}
