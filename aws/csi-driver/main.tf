data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  namespace                       = "kube-system"
  controller_service_account_name = "efs-csi-controller-sa"
  node_service_account_name       = "efs-csi-node-sa"
  role_name                       = "${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole"
}

module "efs_csi_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  create_role = true
  role_name   = local.role_name

  role_policy_arns = {
    "AmazonEKS_CSI_EFS_Policy" = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }

  oidc_providers = {
    external_dns = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "${local.namespace}:${local.controller_service_account_name}",
        "${local.namespace}:${local.node_service_account_name}"
      ]
    }
  }
}

resource "helm_release" "kubernetes_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "3.0.3"

  namespace = local.namespace
  timeout   = 600

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = local.controller_service_account_name
          annotations = {
            "eks.amazonaws.com/role-arn" = module.efs_csi_role.iam_role_arn
          }
        }
      }
      node = {
        serviceAccount = {
          create = true
          name   = local.node_service_account_name
          annotations = {
            "eks.amazonaws.com/role-arn" = module.efs_csi_role.iam_role_arn
          }
        }
      }
    })
  ]
}

resource "kubernetes_storage_class" "storage_class" {
  depends_on = [helm_release.kubernetes_efs_csi_driver]

  storage_provisioner    = "efs.csi.aws.com"
  reclaim_policy         = var.reclaim_policy
  allow_volume_expansion = true
  metadata {
    name = "env0-state-sc"
  }
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
  }
}
