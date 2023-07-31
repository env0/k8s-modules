locals {
  vpc_id                             = module.vpc[0].vpc_id 
  efs_id                             = module.efs.efs_id
  cluster_certificate_authority_data = module.eks[0].cluster_certificate_authority_data
  cluster_endpoint                   = module.eks[0].cluster_endpoint
  private_subnets_ids                = module.vpc[0].private_subnets
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

module "efs" {
  #count        = var.modules_info.efs.create ? 1 : 0
  depends_on = [module.eks, module.vpc]
  source     = "./efs"

  region       = var.region
  vpc_id       = local.vpc_id
  cluster_name = var.cluster_name
  subnets      = local.private_subnets_ids
  allowed_security_group_ids = [module.eks[0].node_security_group_id,module.eks[0].cluster_security_group_id] 
}

module "csi_driver" {
  depends_on = [module.eks]
  source     = "./csi-driver"

  efs_id         = module.efs.efs_id
  reclaim_policy = var.reclaim_policy
  cluster_name   = var.cluster_name
}
