variable "cluster_name" {}

variable "managed_node_group_name" {}

variable "enable_irsa" {
  description = "Use IRSA (requires cluster_oidc_issuer_url and oidc_provider_arn). When false, uses EKS Pod Identity"
  type        = bool
  default     = true
}

variable "cluster_oidc_issuer_url" {
  default = null
}

variable "oidc_provider_arn" {
  default = null
}
