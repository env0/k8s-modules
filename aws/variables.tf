## VPC
variable "azs" {
  description = "A list of availability zones names or ids in the region. Empty uses the first 3 available zones that EKS supports"
  type        = list(string)
  default     = []
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"

  default = "172.16.0.0/16"
}

variable "private_subnets_cidr_blocks" {
  description = "List of private subnets inside the VPC"

  default = ["172.16.0.0/21", "172.16.16.0/21", "172.16.32.0/21", "172.16.48.0/21", "172.16.64.0/21"]
}

variable "public_subnets_cidr_blocks" {
  description = "List of public subnets inside the VPC"

  default = ["172.16.8.0/22", "172.16.24.0/22", "172.16.40.0/22", "172.16.56.0/22", "172.16.72.0/22"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used to name the VPC, EFS and IAM roles"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Keep cluster_autoscaler_chart_version on a chart built for the same minor version"
  type        = string
  default     = "1.35"
}

variable "cluster_autoscaler_chart_version" {
  description = "cluster-autoscaler Helm chart version. Its cluster-autoscaler minor version must match the kubernetes_version minor version. The default 9.59.0 ships cluster-autoscaler 1.35. For other versions run: helm search repo autoscaler/cluster-autoscaler --versions"
  type        = string
  default     = "9.59.0"
}

variable "cluster_access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any

  default = {}
}

variable "min_capacity" {
  description = "Min number of workers"
  default     = 2
}

variable "max_capacity" {
  description = "Max number of workers"
  default = 20
}

variable "instance_types" {
  default = [
    "t3a.2xlarge",
    "t3a.xlarge",
    "t3.2xlarge",
    "t3.xlarge"
  ]
  type = list(string)
}

variable "capacity_type" {
  default = "SPOT"
}

variable "region" {
  default = "us-east-1"
}

## EFS
variable "create_efs_storage" {
  description = "Create EFS and the EFS CSI driver for the agent state PVC (env0-state-sc). Set to false when the agent uses env zero-hosted encrypted state (env0StateEncryptionKey Helm value)"
  type        = bool
  default     = true
}

variable "reclaim_policy" {
  default = "Retain"
}

variable "enable_calico" {
  description = "Enable Calico for network policy enforcement"
  default     = false
  type        = bool
}

variable "calico_docker_hub_credentials" {
  description = "Deprecated and ignored. Calico v3.30 and later pull their images from quay.io, so it needs no Docker Hub credentials"
  type = object({
    username = string
    password = string
    email    = string
  })
  default = null
  sensitive = true
}

variable "coredns_version" {
  description = "coredns EKS addon version. null uses the default version for kubernetes_version"
  type        = string
  default     = null
}

variable "kube_proxy_version" {
  description = "kube-proxy EKS addon version. null uses the default version for kubernetes_version"
  type        = string
  default     = null
}

variable "vpc_cni_version" {
  description = "vpc-cni EKS addon version. null uses the default version for kubernetes_version"
  type        = string
  default     = null
}
