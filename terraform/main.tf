# Setup

provider "google" {
  project = "lehmann-tech"
  region  = "europe-west1"
}

provider "google-beta" {
  project = "lehmann-tech"
  region  = "europe-west1"
}


# Common/global resources

resource "google_compute_ssl_policy" "ssl_policy" {
  name            = "ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_dns_managed_zone" "dns_zone_unwanted_fun" {
  name     = "unwanted-fun"
  dns_name = "unwanted.fun."
}

variable "sql_user_backend_password" {
  type = "string"
  description = "Password of the Cloud SQL database 'backend' user."
}

# dev environment

module "dev_environment" {
  source = "./environments"

  cluster_name     = "dev"
  is_regional      = false
  cluster_location = "europe-west1-c" # zonal cluster
  dns_zone_name    = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name         = "dev.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"

  sql_user_backend_password = var.sql_user_backend_password
}

# staging environment

module "staging_environment" {
  source = "./environments"

  cluster_name     = "staging"
  is_regional      = false
  cluster_location = "europe-west1-b" # zonal cluster
  dns_zone_name    = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name         = "staging.${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"

  sql_user_backend_password = var.sql_user_backend_password
}

module "prod_environment" {
  source = "./environments"

  cluster_name     = "prod"
  is_regional      = true
  cluster_location = "europe-west1" # regional cluster
  dns_zone_name    = "${google_dns_managed_zone.dns_zone_unwanted_fun.name}"
  dns_name         = "${google_dns_managed_zone.dns_zone_unwanted_fun.dns_name}"

  sql_user_backend_password = var.sql_user_backend_password
}
