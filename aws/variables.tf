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

variable "instance_type" {
  default = "t3a.2xlarge" # 8vCPUs 32GB
}

variable "reclaim_policy" {
  default = "Retain"
}

variable "vpc" {
  type = object({
    create = bool
    vpc_id = string
  })
  default = {
    create = true
    vpc_id = ""
  }
  description = "should create a vpc or provisioned by user"

  validation {
    condition = !(var.vpc.create == false && var.vpc.vpc_id == "")
    error_message = "you must specify vpc_id if you don't want it to be created"
  }
}

variable "create_eks" {
  type = bool
  default = true
  description = "should create an eks or provisioned by user"
}

variable "efs" {
  type = object({
    create = bool
    efs_id = string
  })
  default = {
    create = true
    efs_id = ""
  }
  description = "should create an efs or provisioned by user"

  validation {
    condition = !(var.efs.create == false && var.efs.efs_id == "")
    error_message = "you must specify efs_id if you don't want it to be created"
  }
}

variable "create_autoscaler" {
  type = bool
  default = true
  description = "should create an autoscaler or provisioned by user"
}

variable "create_csi_driver" {
  type = bool
  default = true
  description = "should create a csi driver or provisioned by user"
}
