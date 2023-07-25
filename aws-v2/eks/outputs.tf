output "kubernetes_host" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "EKS cluster id"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "EKS cluster cert auth data"
}