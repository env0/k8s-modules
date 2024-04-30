output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value = module.vpc.private_subnets
}