provider "google" {}

// Used to configure the k8s provider
data "google_client_config" "provider" {}
data "google_container_cluster" "my_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

provider "kubectl" {
  host = "https://${data.google_container_cluster.my_cluster.endpoint}"
  cluster_ca_certificate = base64decode(
  data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
  token            = data.google_client_config.provider.access_token
  load_config_file = false
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.my_cluster.endpoint}"
  cluster_ca_certificate = base64decode(
  data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
  token            = data.google_client_config.provider.access_token
}

module "pd_backed_nfs_server" {
  source     = "./pd-backed-nfs-server"
}

