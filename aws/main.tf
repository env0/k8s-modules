
module "oidc-provider-data" {
  depends_on = [module.eks]
  source = './oidc-provider-data'
  cluster_name = var.cluster_name
}

module "vpc" {
  source = "./vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "eks" {
  depends_on = [module.vpc]
  source     = "./eks"

  vpc_id        = module.vpc.vpc_id
  cluster_name  = var.cluster_name
  map_roles     = var.map_roles
  min_capacity  = var.min_capacity
  instance_type = var.instance_type
}

module "efs" {
  depends_on = [module.eks, module.vpc]
  source     = "./efs"

  region       = var.region
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
  subnets      = module.vpc.private_subnets
}

module "autoscaler" {
  depends_on = [module.eks]
  source     = "./autoscaler"

  cluster_name = var.cluster_name
}

module "csi_driver" {
  depends_on = [module.efs, module.oidc-provider-data]
  source     = "./csi-driver"
  arn = module.oidc-provider-data.arn
  efs_id         = module.efs.efs_id
  reclaim_policy = var.reclaim_policy
  cluster_name   = var.cluster_name
}
