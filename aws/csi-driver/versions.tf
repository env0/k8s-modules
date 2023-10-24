terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws        = "~> 3.68.0"
    kubernetes = "~> 2.11.0"
    helm       = "~> 2.10.1"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
