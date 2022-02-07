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

variable "modules_info" {
  type = object({
    vpc = object({
      create = bool
      id = string
      private_subnets = list(string)
    })
    eks = object({
      create = bool
      cluster_id = string
    })
    efs = object ({
      create = bool
      id = string
    })
    autoscaler = object ({
      create = bool
    })
    csi_driver = object({
      create = bool
    })
  })

  default = {
    vpc = {
      create = true
      id = ""
      private_subnets = []
    }
    eks = {
      create = true
      cluster_id = ""
    }
    efs = {
      create = true
      id = ""
    }
    autoscaler = {
      create = true
    }
    csi_driver = {
      create = true
    }
  }

  validation {
    condition = !(!var.modules_info.vpc.create && (var.modules_info.vpc.id == "" || length(var.modules_info.vpc.private_subnets) == 0))
    error_message = "You must specify vpc_id and private_subnets if you don't want the vpc to be created."
  }

  validation {
    condition = !(!var.modules_info.eks.create && var.modules_info.eks.cluster_id == "")
    error_message = "You must specify cluster_id if you don't want the eks to be created."
  }

  validation {
    condition = !(!var.modules_info.eks.create && var.modules_info.vpc.create)
    error_message = "You can't provision eks without vpc."
  }

  validation {
    condition = !(!var.modules_info.efs.create && var.modules_info.efs.create)
    error_message = "You can't proviosn efs without eks."
  }

  validation {
    condition = !(!var.modules_info.autoscaler.create && var.modules_info.eks.create)
    error_message = "You can't proviosn autoscaler without eks."
  }

  validation {
    condition = !(!var.modules_info.csi_driver.create && var.modules_info.efs.create)
    error_message = "You can't proviosn csi_driver without efs."
  }
}