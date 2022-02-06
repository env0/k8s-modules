data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

locals {
  cluster_oidc_issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  oidc_without_http = replace(local.cluster_oidc_issuer_url, "https://", "")
}

module "oidc-provider-data" {
  source = "../oidc-provider-data"
  cluster_name = var.cluster_name
}

resource "aws_iam_role" "role_with_web_identity_oidc" {
  name               = "${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : module.oidc-provider-data.arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/issues/748
            "${local.oidc_without_http}:aud" : "sts.amazonaws.com",
            "${local.oidc_without_http}:sub" : "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })
  inline_policy {
    name = "${var.cluster_name}_AmazonEKS_EFS_CSI_Driver_Policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Effect : "Allow",
          Action : [
            "elasticfilesystem:DescribeAccessPoints",
            "elasticfilesystem:DescribeFileSystems"
          ],
          Resource : "*"
        },
        {
          Effect : "Allow",
          Action : [
            "elasticfilesystem:CreateAccessPoint"
          ],
          Resource : "*",
          Condition : {
            "StringLike" : {
              "aws:RequestTag/efs.csi.aws.com/cluster" : "true"
            }
          }
        },
        {
          Effect : "Allow",
          Action : "elasticfilesystem:DeleteAccessPoint",
          Resource : "*",
          Condition : {
            "StringEquals" : {
              "aws:ResourceTag/efs.csi.aws.com/cluster" : "true"
            }

          }
        }
      ]
    })
  }
}

resource "kubernetes_service_account" "csi_service_account" {
  # Without the extra labels / annotations Helm fails the deployment - invalid ownership metadata error
  metadata {
    name = "efs-csi-controller-sa"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by": "Helm"
      "app.kubernetes.io/name": "aws-efs-csi-driver"
    }
    annotations = {
      "meta.helm.sh/release-name": "aws-efs-csi-driver"
      "meta.helm.sh/release-namespace": "kube-system"
      "eks.amazonaws.com/role-arn": aws_iam_role.role_with_web_identity_oidc.arn
    }
  }
}


resource "helm_release" "kubernetes_efs_csi_driver" {
  depends_on = [
    aws_iam_role.role_with_web_identity_oidc,
    kubernetes_service_account.csi_service_account
  ]
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  timeout    = 600

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
    type  = "string"
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver"
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
    type  = "string"
  }
}

resource "kubernetes_storage_class" "storage_class" {
  depends_on = [helm_release.kubernetes_efs_csi_driver]

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy = var.reclaim_policy
  allow_volume_expansion = true
  metadata {
    name = "env0-state-sc"
  }
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId = var.efs_id
    directoryPerms = "700"
  }
}
