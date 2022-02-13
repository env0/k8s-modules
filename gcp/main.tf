provider "google" {}

// Used to configure the k8s provider
data "google_client_config" "provider" {}
data "google_container_cluster" "my_cluster" {
  name     = var.cluster_name
  location = var.cluster_location
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.my_cluster.endpoint}"
  cluster_ca_certificate = base64decode(
  data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
  token            = data.google_client_config.provider.access_token
}

provider "helm" {
  kubernetes {
    host = "https://${data.google_container_cluster.my_cluster.endpoint}"
    cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
    token            = data.google_client_config.provider.access_token
  }
}

resource "helm_release" "nfs_server_provisioner" {
  name       = "nfs-server-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/"
  chart      = "nfs-server-provisioner"
  timeout    = 600

  values = [
    "${file("${path.module}/values.yaml")}"
  ]
}

