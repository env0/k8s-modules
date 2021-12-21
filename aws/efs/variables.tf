variable "cluster_name" {}

variable "region" {}

variable "vpc_id" {
  description = "The id of the specific VPC to using"
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"

  default = ["172.16.0.0/21", "172.16.16.0/21", "172.16.32.0/21", "172.16.48.0/21", "172.16.64.0/21"]
}