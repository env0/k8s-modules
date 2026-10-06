variable "cluster_name" {}

variable "managed_node_group_name" {}

variable "cluster_oidc_issuer_url" {}

variable "oidc_provider_arn" {}

variable "helm_chart_version" {
  description = "cluster-autoscaler Helm chart version. Must match the cluster Kubernetes minor version"
  default     = "9.59.0"
}
