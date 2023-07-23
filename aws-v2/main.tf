data "aws_eks_cluster" "my_eks" {
  count = var.modules_info.eks.create ? 0 : 1
  name  = var.modules_info.eks.cluster_id
}

locals {
  vpc_id          = var.modules_info.vpc.create ? module.vpc[0].vpc_id : var.modules_info.vpc.id
  private_subnets = var.modules_info.vpc.create ? module.vpc[0].private_subnets : var.modules_info.vpc.private_subnets
#   efs_id          = var.modules_info.efs.create ? module.efs[0].efs_id : var.modules_info.efs.id
}


module "vpc" {
  #   count           = var.modules_info.vpc.create ? 1 : 0
  count  = 1
  source = "../aws/vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  depends_on = [module.vpc]
  count      = var.modules_info.eks.create ? 1 : 0
  source     = "./eks"

  vpc_id        = local.vpc_id
  cluster_name  = var.cluster_name
  map_roles     = var.map_roles
  min_capacity  = var.min_capacity
  instance_type = var.instance_type
}
