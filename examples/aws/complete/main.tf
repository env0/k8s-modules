
locals {
  cluster_endpoint                   = var.create ? module.k8s_cluster.cluster_endpoint : data.aws_eks_cluster.my_eks[0].endpoint
  cluster_certificate_authority_data = var.create ? module.k8s_cluster.cluster_certificate_authority_data : data.aws_eks_cluster.my_eks[0].certificate_authority[0].data
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "my_eks" {
  count = var.create ? 0 : 1
  name  = var.cluster_name
}


provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(local.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}


module "k8s_cluster" {
  source       = "../../../aws"
  cluster_name = var.cluster_name
  aws_auth_roles = var.aws_auth_roles
}
