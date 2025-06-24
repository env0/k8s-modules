terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws        = ">= 5.40.0, < 6.0.0"
    helm       = ">= 2.13.0, < 3.0.0"
    kubernetes = ">= 2.29.0, < 3.0.0"
  }
}
