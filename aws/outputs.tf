output "cluster_endpoint" {
  value       = try(local.cluster_endpoint, null)
  description = "EKS cluster host endpoint"
}


output "cluster_certificate_authority_data" {
  value = try(local.cluster_certificate_authority_data, null)
}
