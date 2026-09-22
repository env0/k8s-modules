variable "enable_irsa" {
  description = "Use IRSA (requires oidc_provider_arn). When false, uses EKS Pod Identity"
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  default = null
}

variable "cluster_name" {}

variable "reclaim_policy" {
  default = "Retain"
}

variable "efs_id" {}

