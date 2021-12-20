output "kubernetes_host" {
  value       = data.aws_eks_cluster.cluster.endpoint
  description = "EKS cluster host endpoint"
}

output "kubernetes_cluster_ca_certificate" {
  value       = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  sensitive   = true
  description = "EKS cluster certificate"
}

output "cluster_id" {
  value       = data.aws_eks_cluster.cluster.id
  description = "EKS cluster id"
}

output "cluster_name" {
  value       = data.aws_eks_cluster.cluster.name
  description = "EKS cluster name"
}
