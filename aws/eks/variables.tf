variable "cluster_name" {}

variable "vpc_id" {
  description = "The id of the specific VPC to using"
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

variable "min_capacity" {
  description = "Min number of workers"
  default = 2
}

variable "instance_type" {
  default = "t3a.2xlarge" # 8vCPUs 32GB
}

variable "write_kubeconfig" {
  type = bool
  default = false 
}

variable "aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  # TODO: remove this deafult value before merge
  default = [
    {
      "rolearn": "arn:aws:iam::343806850935:role/AWSReservedSSO_AdministratorAccess_9999c6a81f899fc6",
      "groups": ["system:masters"],
      "username": "anv0 kushield admin"
    }
]
}