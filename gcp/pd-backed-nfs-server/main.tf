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
resource "google_compute_disk" "env0_internal_state_disk" {
  name = "env0_internal_state_disk"
  type = "pd-ssd"
  size = "300" // GB
}

// The kubectl full manifest
data "template_file" "nfs_server_k8s_yaml" {
  template = file("./nfs-server.yaml")
  vars = {
    pdName = google_compute_disk.env0_internal_state_disk.name
    pdZone = google_compute_disk.env0_internal_state_disk.zone
  }
}

// Used to split the K8S manifest to the separate components
data "kubectl_file_documents" "nfs_server_k8s_docs" {
  content = data.template_file.nfs_server_k8s_yaml.rendered
}

// Applies the K8S manifests
resource "kubectl_manifest" "nfs_server_k8s_manifest" {
  depends_on = [
    data.kubectl_file_documents.nfs_server_k8s_docs
  ]
  for_each  = data.kubectl_file_documents.nfs_server_k8s_docs.manifests
  yaml_body = each.value
}
