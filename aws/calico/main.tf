# v3.31 is the last chart line that ships the Calico CRDs (crds/). From v3.32 the
# CRDs live in a separate chart. Helm installs crds/ only on install, so an
# upgrade needs the CRDs applied first, see the README upgrade notes.
resource "helm_release" "calico" {
  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  version    = "v3.31.7"

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
