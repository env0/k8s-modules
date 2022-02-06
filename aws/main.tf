data aws_vpc "my_vpc" {
  count = var.vpc.create ? 0 : 1
  id = var.vpc.vpc_id
}

data aws_eks_cluster "my_eks" {
  count = var.eks.create ? 0 : 1
  name = var.eks.cluster_id
}

locals {
  vpc_id = (var.efs.create && var.eks.create && var.vpc.create) ? module.vpc[0].vpc_id : var.vpc.vpc_id
  private_subnets = (var.efs.create && var.eks.create && var.vpc.create) ? module.vpc[0].private_subnets : data.aws_vpc.my_vpc[0].private_subnets
  efs_id = var.efs.create ? module.efs[0].efs_id : var.efs.efs_id
}

module "vpc" {
  count           = var.vpc.create ? 1 : 0
  source          = "./vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  depends_on = [module.vpc]
  count         = var.eks.create ? 1 : 0
  source     = "./eks"

  vpc_id        = local.vpc_id
  cluster_name  = var.cluster_name
  map_roles     = var.map_roles
  min_capacity  = var.min_capacity
  instance_type = var.instance_type
}

module "efs" {
  count        = var.efs.create ? 1 : 0
  depends_on   = [module.eks, module.vpc]
  source       = "./efs"

  region       = var.region
  vpc_id       = local.vpc_id
  cluster_name = var.cluster_name
  subnets      = local.private_subnets
}

module "autoscaler" {
  count      = var.create_autoscaler ? 1 : 0
  depends_on = [module.eks]
  source     = "./autoscaler"

  cluster_name = var.cluster_name
}

module "csi_driver" {
  count      = var.create_csi_driver ? 1 : 0
  depends_on = [module.efs]
  source     = "./csi-driver"

  efs_id         = local.efs_id
  reclaim_policy = var.reclaim_policy
  cluster_name   = var.cluster_name
}
