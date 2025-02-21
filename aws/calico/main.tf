locals {
  docker_config = var.calico_docker_hub_credentials != null ? {
    auths = {
      "docker.io" = {
        username = var.calico_docker_hub_credentials.username
        password = var.calico_docker_hub_credentials.password
        email    = var.calico_docker_hub_credentials.email
        auth = base64encode("${var.calico_docker_hub_credentials.username}:${var.calico_docker_hub_credentials.password}")
      }
    }
  } : null
}


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

  dynamic "set_sensitive" {
    for_each = local.docker_config != null ? [jsonencode({ "calico-image-pull-secret": local.docker_config })] : []
    iterator = config
    content {
      name  = "imagePullSecrets"
      value = config.value
    }
  }
}
