locals {
  vpc_id                             = module.vpc.vpc_id
  efs_id                             = module.efs.efs_id
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_endpoint                   = module.eks.cluster_endpoint
}

module "vpc" {
  source = "./vpc"

  cluster_name = var.cluster_name

  azs                         = var.azs
  cidr                        = var.cidr
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  public_subnets_cidr_blocks  = var.public_subnets_cidr_blocks
}

module "eks" {
  source = "./eks"

  cluster_name = var.cluster_name

  vpc_id     = local.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  min_capacity  = var.min_capacity
  instance_type = var.instance_type

  aws_auth_roles = var.aws_auth_roles
}


module "autoscaler" {
  depends_on = [module.eks]
  source     = "./autoscaler"

  cluster_name            = var.cluster_name
  managed_node_group_name = module.eks.managed_node_group_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn
}

module "efs" {
  depends_on = [module.eks, module.vpc]
  source     = "./efs"

  region                     = var.region
  vpc_id                     = local.vpc_id
  cluster_name               = var.cluster_name
  subnets                    = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.eks.node_security_group_id, module.eks.cluster_security_group_id]
}

module "csi_driver" {
  depends_on = [module.eks]
  source     = "./efs-csi-driver"

  efs_id            = module.efs.efs_id
  reclaim_policy    = var.reclaim_policy

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
}
