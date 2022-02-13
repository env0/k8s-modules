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

resource "helm_release" "nfs_server_provisioner" {
  depends_on = [
    google_compute_region_disk.env0_internal_state_disk
  ]
  name       = "nfs-server-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/"
  chart      = "nfs-server-provisioner"
  timeout    = 600

  values = [
    "${file("./values.yaml")}"
  ]
}
