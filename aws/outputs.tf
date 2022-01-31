output "kubernetes_host" {
  value       = var.eks.create ? module.eks[0].kubernetes_host : var.eks.kubernetes_host
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = var.eks.create ? module.eks[0].cluster_id : var.eks.cluster_id
  description = "EKS cluster id"
}