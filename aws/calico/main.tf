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

  set {
    name = "imagePullSecrets"
    value = jsonencode({
      "calico-image-pull-secret" = var.calico_image_pull_secret
    })
  }
}
