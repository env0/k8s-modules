output "kubernetes_host" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster host endpoint"
}