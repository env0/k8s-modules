terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google     = "~> 4.7.0"
    kubernetes = "~> 2.7.0"
    helm       = "~> 2.4.0"        
  }
}
