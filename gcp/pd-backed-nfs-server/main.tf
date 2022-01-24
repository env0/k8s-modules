locals {
  manifests = [
    "deployment",
    "pv-for-deployment-pods",
    "pv-for-nfs-server",
    "pvc-for-nfs-server",
    "service",
  ]
}

provider "kubectl" {
  host = "https://${data.google_container_cluster.my_cluster.endpoint}"
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
  token            = data.google_client_config.provider.access_token
  load_config_file = false
}

provider "google" {}

// Used to configure the kubectl provider
data "google_client_config" "provider" {}
data "google_container_cluster" "my_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

// The disk used to back the NFS Server
resource "google_compute_region_disk" "env0_internal_state_disk" {
  name = "env0-internal-state-disk"
  type = "pd-standard"
  size = "300" // GB
  region = "us-central1"
  replica_zones = [ "us-central1-a", "us-central1-b", ]
}

// K8S Manifests
resource "kubectl_manifest" "nfs_server_deployment" {
  for_each = toset(local.manifests)
  yaml_body = file("./manifests/${each.value}.yaml")
}

