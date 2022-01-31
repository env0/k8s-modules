output "kubernetes_host" {
  value       = module.eks[0].cluster_endpoint
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = module.eks[0].cluster_id
  description = "EKS cluster id"
}