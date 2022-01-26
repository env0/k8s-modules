variable "cluster_name" {}

variable "reclaim_policy" {
  default = "Retain"
}

variable "efs_id" {}

variable "eks_oidc_provider_arn" {}
