resource "helm_release" "calico" {
  repository = "https://docs.projectcalico.org/charts/"
  chart      = "tigera-operator"
  version    = "3.27.3"

  name             = "calico"
  namespace        = "tigera-operator"
  create_namespace = true

  timeout = 600

  set {
    name = "apiServer.enabled"
    value = "false"
  }

  dynamic "set" {
    for_each = var.calico_docker_hub_credentials != null ? [var.calico_docker_hub_credentials] : []
    content {
      name  = "imagePullSecrets[0].username"
      value = set.value.username
    }
  }

  dynamic "set_sensitive" {
    for_each = var.calico_docker_hub_credentials != null ? [var.calico_docker_hub_credentials] : []
    content {
      name  = "imagePullSecrets[0].password"
      value = set.value.password
    }
  }

  dynamic "set" {
    for_each = var.calico_docker_hub_credentials != null ? [var.calico_docker_hub_credentials] : []
    content {
      name  = "imagePullSecrets[0].email"
      value = set.value.email
    }
  }

}
