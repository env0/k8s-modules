variable "cluster_name" {}

variable "kubernetes_version" {}

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

variable "cluster_access_entries" {}
