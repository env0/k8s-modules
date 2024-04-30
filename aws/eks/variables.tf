variable "cluster_name" {}

variable "vpc_id" {
  description = "The id of the specific VPC to using"
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
}

variable "min_capacity" {
  description = "Min number of workers"
  default     = 2
}

variable "instance_type" {
  default = "t3a.2xlarge" # 8vCPUs 32GB
}

variable "write_kubeconfig" {
  type    = bool
  default = false
}

variable "aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  
  default = []
}