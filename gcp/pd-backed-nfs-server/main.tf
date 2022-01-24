resource "google_compute_disk" "env0_internal_state_disk" {
  name = "env0_internal_state_disk"
  type = "pd-ssd"
  size = "300" // GB
}

data "template_file" "nfs_server_k8s_yaml" {
  template = file("./nfs-server.yaml")
  vars = {
    pdName = google_compute_disk.env0_internal_state_disk.name
    pdZone = google_compute_disk.env0_internal_state_disk.zone
  }
}

data "kubectl_file_documents" "nfs_server_k8s_docs" {
  content = data.nfs_server_k8s_yaml.rendered
}

resource "kubectl_manifest" "nfs_server_k8s_manifest" {
  for_each  = data.nfs_server_k8s_docs.docs.manifests
  yaml_body = each.value
}
