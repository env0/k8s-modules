variable "region" {}

variable "cluster_name" {}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "min_capacity" {
  description = "Min number of workers"
  default = 2
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"

  default = null
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"

  default = null
}

variable "public_subnets" {
  description = "List of public subnets inside the VPC"

  default = null
}

variable "instance_type" {
  default = null
}

variable "reclaim_policy" {
  default = null
}