resource "helm_release" "calico" {
  repository = "https://docs.projectcalico.org/charts/"
  chart      = "tigera-operator"
  version    = "3.27.3"

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
          var.calico_docker_hub_credentials != null ? {
          imagePullSecrets = {
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
        } : {}
      )
    )
  ]
}
