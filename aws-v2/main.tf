locals {
  vpc_id          =  data.aws_eks_cluster.my_eks.vpc_config[0].vpc_id
  #efs_id          = data.aws_efs_access_point.my_efs
  cluster_endpoint = data.aws_eks_cluster.my_eks.endpoint
  cluster_certificate_authority_data = data.aws_eks_cluster.my_eks.certificate_authority[0].data
}

data aws_eks_cluster "my_eks" {
  name = var.cluster_name
}


# TODO figure out why we destroy it when I run plan for all modules
module "vpc" {
  #count = local.vpc_id != "" ? 0 : 1
  source = "../aws/vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
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

module "eks" {
  # depends_on = [module.vpc]
  #count      = var.modules_info.eks.create ? 1 : 0
  source     = "./eks"

  vpc_id        = local.vpc_id
  cluster_name  = var.cluster_name
  map_roles     = var.map_roles
  min_capacity  = var.min_capacity
  instance_type = var.instance_type
}


# module "autoscaler" {
#   count      = var.modules_info.autoscaler.create ? 1 : 0
#   # depends_on = [module.eks]
#   source     = "../aws/autoscaler"

#   cluster_name = var.cluster_name
# }


# EFS and CSI driver should be deployed together
module "efs" {
  #count        = var.modules_info.efs.create ? 1 : 0
  #depends_on   = [module.eks, module.vpc]
  source       = "../aws/efs"

  region       = var.region
  vpc_id       = local.vpc_id
  cluster_name = var.cluster_name
  subnets      = var.private_subnets
}

module "csi_driver" {
  #count      = var.modules_info.csi_driver.create ? 1 : 0
  # depends_on = [module.efs]
  source     = "../aws/csi-driver"

  efs_id         = module.efs.efs_id
  reclaim_policy = var.reclaim_policy
  cluster_name   = var.cluster_name
}