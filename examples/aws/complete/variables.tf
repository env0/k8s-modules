variable "create" {
  type    = bool
  default = true
}

variable "aws_auth_roles" {
  default = []
}

variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {}