output "kubernetes_host" {
  value       = module.eks.create ? module.eks.kubernetes_host : var.eks.kubernetes_host
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = module.eks.create ? module.eks.cluster_id : var.eks.cluster_id
  description = "EKS cluster id"
}