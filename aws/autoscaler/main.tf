data "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.managed_node_group_name
}

locals {
  autoscaling_group_name = data.aws_eks_node_group.node_group.resources.0.autoscaling_groups.0.name
  namespace              = "cluster-autoscaler"
  service_account_name   = "cluster-autoscaler"
}

# Same permissions lablabs/eks-cluster-autoscaler grants its IRSA role
data "aws_iam_policy_document" "autoscaler" {
  count = var.enable_irsa ? 0 : 1

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "autoscaler" {
  count = var.enable_irsa ? 0 : 1

  name   = "${var.cluster_name}-cluster-autoscaler"
  policy = data.aws_iam_policy_document.autoscaler[0].json
}

module "autoscaler_pod_identity" {
  count = var.enable_irsa ? 0 : 1

  source = "../pod-identity"

  cluster_name = var.cluster_name
  role_name    = "${var.cluster_name}-cluster-autoscaler"
  policy_arns  = { autoscaler = aws_iam_policy.autoscaler[0].arn }

  service_accounts = {
    autoscaler = { namespace = local.namespace, name = local.service_account_name }
  }
}

module "eks-cluster-autoscaler" {
  # Pod Identity injects credentials only into pods created after the association exists
  depends_on = [module.autoscaler_pod_identity]

  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "2.2.0"

  cluster_name                     = var.cluster_name
  cluster_identity_oidc_issuer     = var.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.oidc_provider_arn
  irsa_role_create                 = var.enable_irsa

  namespace            = local.namespace
  service_account_name = local.service_account_name

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
