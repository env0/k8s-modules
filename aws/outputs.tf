output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = try(local.cluster_endpoint, null)
  description = "EKS cluster host endpoint"
}


output "cluster_certificate_authority_data" {
  value = try(local.cluster_certificate_authority_data, null)
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "ARN of the cluster OIDC provider, for IAM roles for service accounts (IRSA)"
}
