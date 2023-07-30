output "cluster_endpoint" {
  value       =  try(local.cluster_endpoint, null) #? module.eks[0].cluster_endpoint : data.aws_eks_cluster.my_eks[0].endpoint
  description = "EKS cluster host endpoint"
}


output "cluster_certificate_authority_data" {
  value = try(local.cluster_certificate_authority_data, null)
}



