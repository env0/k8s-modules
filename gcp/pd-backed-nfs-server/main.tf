locals {
  manifests = [
    "deployment",
    "pv-for-deployment-pods",
    "pv-for-nfs-server",
    "pvc-for-nfs-server",
    "service",
  ]
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
# resource "kubernetes_manifest" "nfs_server_deployment" {
#   depends_on = [
#     google_compute_region_disk.env0_internal_state_disk
#   ]
#   for_each = toset(local.manifests)
#   manifest = yamldecode(file("${path.module}/manifests/${each.value}.yaml"))
# }

