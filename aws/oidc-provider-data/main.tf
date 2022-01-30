data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  partition    = data.aws_partition.current.id
  account_id   = data.aws_caller_identity.current.account_id
  url_stripped = replace(local.issuer_url, "https://", "")
  arn          = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.url_stripped}"
}
