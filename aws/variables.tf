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
    condition = !(var.modules_info.vpc.create == false && (var.modules_info.vpc.id == "" || length(var.modules_info.vpc.private_subnets) == 0))
    error_message = "You must specify vpc_id if and private_subnets you don't want the vpc to be created."
  }

  validation {
    condition = !(var.modules_info.eks.create == false && var.modules_info.eks.cluster_id == "")
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

variable "vpc" {
  type = object({
    create = bool
    vpc_id = string
    private_subnets = list(string)
  })
  default = {
    create = true
    vpc_id = ""
    private_subnets = []
  }
  description = "should create a vpc or provisioned by user"

  validation {
    condition = !(var.vpc.create == false && (var.vpc.vpc_id == "" || length(var.vpc.private_subnets) == 0))
    error_message = "You must specify vpc_id if you don't want it to be created."
  }
}

variable "eks" {
    type = object({
    create          = bool
    kubernetes_host = string
    cluster_id      = string
  })

  default = {
    create = true
    kubernetes_host = ""
    cluster_id      = ""
  }

  validation {
    condition = !(var.eks.create == false && (var.eks.kubernetes_host == "" || var.eks.cluster_id == ""))
    error_message = "You must specify kubernetes_host and cluster_id if you don't want it to be created."
  }

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
    error_message = "You must specify efs_id if you don't want it to be created."
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
