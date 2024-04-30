variable "cluster_name" {}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
}

variable "private_subnets_cidr_blocks" {
  description = "List of private subnets inside the VPC"
}

variable "public_subnets_cidr_blocks" {
  description = "List of public subnets inside the VPC"
}
