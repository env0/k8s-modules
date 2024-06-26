variable "cluster_name" {}

variable "region" {}

variable "vpc_id" {
  description = "The id of the specific VPC to using"
}

variable "subnets" {}

variable "allowed_security_group_ids" {
  default = []
}
