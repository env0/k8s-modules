resource "helm_release" "calico" {
  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  version    = "v3.33.0"

  name             = "calico"
  namespace        = "tigera-operator"
  create_namespace = true

  timeout = 600

  values = [
    yamlencode({
      apiServer = {
        enabled = false
      }
    })
  ]
}
