output "kubernetes_host" {
  value       = module.eks.cluster_endpoint #,data.aws_eks_cluster.my_eks.endpoint)
  description = "EKS cluster host endpoint"
}

# output "cluster_id" {
#   value       = var.modules_info.eks.create ? module.eks.cluster_id : var.modules_info.eks.cluster_id
#   description = "EKS cluster id"
# }