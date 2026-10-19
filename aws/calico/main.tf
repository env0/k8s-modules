locals {
  calico_version = "v3.33.0"
  region_flag    = var.region == null ? "" : "--region ${var.region}"
}

# From v3.32 the tigera-operator chart no longer ships the CRDs, and Helm never
# upgraded the ones it did ship. Apply them before every chart install or upgrade.
# Server-side, because some Calico CRDs are too large for client-side apply.
resource "null_resource" "crds" {
  triggers = {
    calico_version = local.calico_version
    cluster_name   = var.cluster_name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-SCRIPT
      set -euo pipefail
      dir=$(mktemp -d)
      trap 'rm -rf "$dir"' EXIT
      export KUBECONFIG="$dir/config"
      aws eks update-kubeconfig --name ${var.cluster_name} ${local.region_flag} >/dev/null
      kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/projectcalico/calico/${local.calico_version}/manifests/v1_crd_projectcalico_org.yaml
    SCRIPT
  }
}

resource "helm_release" "calico" {
  depends_on = [null_resource.crds]

  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  version    = local.calico_version

  name             = "calico"
  namespace        = "tigera-operator"
  create_namespace = true

  timeout = 600

  # From v3.33 goldmane and whisker need the projectcalico.org/v3 API, which the
  # disabled API server would serve, and stay degraded without it.
  values = [
    yamlencode({
      apiServer = {
        enabled = false
      }
      goldmane = {
        enabled = false
      }
      whisker = {
        enabled = false
      }
    })
  ]
}
