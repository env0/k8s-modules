variable "cluster_name" {}

variable "role_name" {}

variable "policy_arns" {
  description = "Map of policy ARNs to attach to the role, keyed by an arbitrary id"
  type        = map(string)
}

variable "service_accounts" {
  description = "Service accounts to associate with the role, keyed by an arbitrary id"
  type = map(object({
    namespace = string
    name      = string
  }))
}
