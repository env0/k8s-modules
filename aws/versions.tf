terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws        = ">= 5.95.0, < 6.0.0"
    helm       = "< 4.0.0"
    kubernetes = ">= 2.29.0, < 3.0.0"
  }
}
