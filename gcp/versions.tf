terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google     = ">= 4.85.0, < 5.0.0"
    kubernetes = ">= 2.38.0, < 3.0.0"
    helm       = ">= 2.17.0, < 3.0.0"
  }
}
