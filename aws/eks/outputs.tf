output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "EKS cluster id"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "EKS cluster certificate"
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
  description = "ID of the node shared security group"
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}