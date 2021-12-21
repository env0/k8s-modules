terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws        = "~> 3.68.0"
    kubernetes = "~> 2.7.0"
    helm       = "~> 2.4.0"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
