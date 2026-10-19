variable "cluster_name" {}

variable "managed_node_group_name" {}

variable "cluster_oidc_issuer_url" {}

variable "oidc_provider_arn" {}

variable "region" {
  description = "AWS region of the cluster. null uses the AWS CLI default region"
  type        = string
  default     = null
}

variable "helm_chart_version" {
  description = "cluster-autoscaler Helm chart version. Must match the cluster Kubernetes minor version"
  default     = "9.59.0"
}

variable "image_tag" {
  description = "cluster-autoscaler image tag, for a Kubernetes minor version that no chart ships yet. null uses the chart's image"
  type        = string
  default     = null
}
