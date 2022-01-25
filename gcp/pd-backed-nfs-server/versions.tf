terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google   = "4.7.0"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.1"
    }
  }
}
