terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google     = "~> 4.7.0"
    kubernetes = "~> 2.11.0"
    helm       = "~> 2.10.1"
  }
}
