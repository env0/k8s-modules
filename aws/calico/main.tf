locals {
  image_pull_secrets = {
    "calico-image-pull-secret": jsonencode({
      auths = {
        "docker.io" = {
          username = var.calico_docker_hub_credentials.username,
          password = var.calico_docker_hub_credentials.password,
          email    = var.calico_docker_hub_credentials.email,
          auth     = base64encode("${var.calico_docker_hub_credentials.username}:${var.calico_docker_hub_credentials.password}")
        }
      }
    })
  }
}

resource "helm_release" "calico" {
  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  version    = "v3.33.0"

  name             = "calico"
  namespace        = "tigera-operator"
  create_namespace = true

  timeout = 600

  values = [
    yamlencode(
      merge(
        {
          apiServer = {
            enabled = false
          }
        },
          var.calico_docker_hub_credentials != null ? { imagePullSecrets = local.image_pull_secrets  } : {}
      )
    )
  ]
}
