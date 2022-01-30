terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google   = "~> 4.7.0"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13.1"
    }
    kubernetes = "~> 2.7.0"
  }
}
