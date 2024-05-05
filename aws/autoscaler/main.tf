data "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.managed_node_group_name
}

locals {
  autoscaling_group_name = data.aws_eks_node_group.node_group.resources.0.autoscaling_groups.0.name
}

module "eks-cluster-autoscaler" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "2.2.0"

  cluster_name                     = var.cluster_name
  cluster_identity_oidc_issuer     = var.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.oidc_provider_arn

  # make sure that chart version matches the cluster version
  helm_chart_version = "9.33.0"

  values = yamlencode({
    # Here you we can further configure the autoscaler:
    # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml
    # extraArgs: {
    #  scale-down-utilization-threshold: local.single_deployment_pod_utilization_of_node_resources
    #}
  })
}

# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#common-notes-and-gotchas
resource "null_resource" "autoscaling_settings" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-SCRIPT
      aws autoscaling suspend-processes --auto-scaling-group-name ${local.autoscaling_group_name} --scaling-processes AZRebalance
      aws autoscaling update-auto-scaling-group --auto-scaling-group-name ${local.autoscaling_group_name} --default-cooldown 60
      aws autoscaling enable-metrics-collection --auto-scaling-group-name ${local.autoscaling_group_name} --granularity "1Minute"
    SCRIPT
  }
}
