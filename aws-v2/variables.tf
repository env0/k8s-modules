
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"

  default = "172.16.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"

  default = ["172.16.0.0/21", "172.16.16.0/21", "172.16.32.0/21", "172.16.48.0/21", "172.16.64.0/21"]
}

variable "public_subnets" {
  description = "List of public subnets inside the VPC"

  default = ["172.16.8.0/22", "172.16.24.0/22", "172.16.40.0/22", "172.16.56.0/22", "172.16.72.0/22"]
}

variable "cluster_name" {
    default = "liran-demo"
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

variable "min_capacity" {
  description = "Min number of workers"
  default = 2
}

variable "instance_type" {
  default = "t3a.2xlarge" # 8vCPUs 32GB
}

variable "region" {
  default = "us-east-1"
}


# existing modules variables

## VPC
variable vpc_id {
  description = "the vpc id"
  default = ""
}

# variable vpc_private_subnets {
#   description = "the vpc private subnets"
#   default = ""
# }


## EFS
variable efs_id {
  description = "the efs id"
  default = ""
}

variable "reclaim_policy" {
  default = "Retain"
}


variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

