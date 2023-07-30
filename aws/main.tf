locals {
  vpc_id = var.modules_info.vpc.create ? module.vpc[0].vpc_id : var.modules_info.vpc.id
  #private_subnets = var.modules_info.vpc.create ? module.vpc[0].private_subnets_cidr_blocks : var.modules_info.vpc.private_subnets_cidr_blocks
  efs_id                             = var.modules_info.efs.create ? module.efs.efs_id : var.modules_info.efs.id
  cluster_certificate_authority_data = var.modules_info.eks.create ? module.eks[0].cluster_certificate_authority_data : data.aws_eks_cluster.my_eks[0].certificate_authority[0].data
  cluster_endpoint                   = var.modules_info.eks.create ? module.eks[0].cluster_endpoint : data.aws_eks_cluster.my_eks[0].endpoint
  private_subnets_ids                = var.modules_info.vpc.create ? module.vpc[0].private_subnets : data.aws_subnets.private[0].ids
}

data "aws_subnets" "private" {
  count = var.modules_info.vpc.create ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "private"
  }
}

data "aws_eks_cluster" "my_eks" {
  count = var.modules_info.eks.create ? 0 : 1
  name  = var.modules_info.eks.cluster_id
}

module "vpc" {
  count  = var.modules_info.vpc.create ? 1 : 0
  source = "./vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets_cidr_blocks
  public_subnets  = var.public_subnets_cidr_blocks
}

module "eks" {
  count  = var.modules_info.eks.create ? 1 : 0
  source = "./eks"

  vpc_id         = local.vpc_id
  cluster_name   = var.cluster_name
  aws_auth_roles = var.aws_auth_roles
  min_capacity   = var.min_capacity
  instance_type  = var.instance_type
}


module "autoscaler" {
  count      = var.modules_info.autoscaler.create ? 1 : 0
  depends_on = [module.eks]
  source     = "./autoscaler"

  cluster_name = var.cluster_name
}


# EFS and CSI driver should be deployed together
module "efs" {
  #count        = var.modules_info.efs.create ? 1 : 0
  depends_on = [module.eks, module.vpc]
  source     = "./efs"

  region       = var.region
  vpc_id       = local.vpc_id
  cluster_name = var.cluster_name
  subnets      = local.private_subnets_ids
}

module "csi_driver" {
  #count      = var.modules_info.csi_driver.create ? 1 : 0
  depends_on = [module.eks]
  source = "./csi-driver"

  efs_id         = module.efs.efs_id
  reclaim_policy = var.reclaim_policy
  cluster_name   = var.cluster_name
}
