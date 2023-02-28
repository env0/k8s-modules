output "kubernetes_host" {
  value       = var.modules_info.eks.create ? module.eks.kubernetes_host : data.aws_eks_cluster.my_eks[0].endpoint
  description = "EKS cluster host endpoint"
}

output "cluster_id" {
  value       = var.modules_info.eks.create ? module.eks.cluster_id : var.modules_info.eks.cluster_id
  description = "EKS cluster id"
}
