data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  namespace            = "kube-system"
  service_account_name = "efs-csi-controller-sa"
  role_name            = "${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole"
}

module "efs_csi_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  create_role = true
  role_name   = local.role_name

  attach_efs_csi_policy = true

  oidc_providers = {
    external_dns = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${local.service_account_name}"]
    }
  }
}

resource "helm_release" "kubernetes_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = local.namespace
  timeout    = 600

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = local.service_account_name
    type  = "string"
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver"
    type  = "string"
  }
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
