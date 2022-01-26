data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-deployment-node-group"
}

locals {
  cluster_oidc_issuer_url = flatten(concat(data.aws_eks_cluster.cluster.identity[*].oidc[0].issuer, [""]))[0]
  autoscaling_group_name = data.aws_eks_node_group.node_group.resources.0.autoscaling_groups.0.name
}

module "eks-cluster-autoscaler" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "1.6.1"

  cluster_name                     = var.cluster_name
  cluster_identity_oidc_issuer     = local.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.eks_oidc_provider_arn


  helm_chart_version = "9.9.2"

  values = yamlencode({
    # Determined by our cluster version -
    # Open the Cluster Autoscaler releases page from GitHub in a web browser and find the latest Cluster Autoscaler version that matches the Kubernetes major and minor version of your cluster.
    # For example, if the Kubernetes version of your cluster is 1.20, find the latest Cluster Autoscaler release that begins with 1.20.
    "image" : {
      "tag" : "v${data.aws_eks_cluster.cluster.version}.0"
    }
    # Here you we can further configure the autoscaler:
    # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/values.yaml#L131
    # We should do so after reviewing https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-deployment-considerations
    # extraArgs: {
    #  scale-down-utilization-threshold: local.single_deployment_pod_utilization_of_node_resources
    #}
  })
}

# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/aws#common-notes-and-gotchas
module "suspend_asg_processes_command" {
  source           = "digitickets/cli/aws"
  version          = "4.1.0"
  aws_cli_commands = ["autoscaling", "suspend-processes", "--auto-scaling-group-name ${local.autoscaling_group_name}", "--scaling-processes AZRebalance"]
}

module "set_asg_default_cooldown_command" {
  source           = "digitickets/cli/aws"
  version          = "4.1.0"
  aws_cli_commands = ["autoscaling", "update-auto-scaling-group", "--auto-scaling-group-name ${local.autoscaling_group_name}", "--default-cooldown 60"]
}

module "enable_asg_metrics_collection" {
  source           = "digitickets/cli/aws"
  version          = "4.1.0"
  aws_cli_commands = ["autoscaling", "enable-metrics-collection ", "--auto-scaling-group-name ${local.autoscaling_group_name}", "--granularity \"1Minute\""]
}
