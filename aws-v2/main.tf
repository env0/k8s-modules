locals {
  vpc_id          = var.modules_info.vpc.create ? module.vpc[0].vpc_id : var.modules_info.vpc.id
  private_subnets = var.modules_info.vpc.create ? module.vpc[0].private_subnets : var.modules_info.vpc.private_subnets
  efs_id          = var.modules_info.efs.create ? module.efs[0].efs_id : var.modules_info.efs.id
}


module "vpc" {
  count           = var.modules_info.vpc.create ? 1 : 0
  source = "../aws/vpc"

  cluster_name    = var.cluster_name
  cidr            = var.cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

module "eks" {
  # depends_on = [module.vpc]
  count      = var.modules_info.eks.create ? 1 : 0
  source     = "./eks"

  vpc_id        = local.vpc_id
  cluster_name  = var.cluster_name
  map_roles     = var.map_roles
  min_capacity  = var.min_capacity
  instance_type = var.instance_type
}

module "efs" {
  count        = var.modules_info.efs.create ? 1 : 0
  depends_on   = [module.eks, module.vpc]
  source       = "../aws/efs"

  region       = var.region
  vpc_id       = local.vpc_id
  cluster_name = var.cluster_name
  subnets      = local.private_subnets
}

# module "autoscaler" {
#   count      = var.modules_info.autoscaler.create ? 1 : 0
#   # depends_on = [module.eks]
#   source     = "../aws/autoscaler"

#   cluster_name = var.cluster_name
# }

# module "csi_driver" {
#   count      = var.modules_info.csi_driver.create ? 1 : 0
#   # depends_on = [module.efs]
#   source     = "../aws/csi-driver"

#   efs_id         = local.efs_id
#   reclaim_policy = var.reclaim_policy
#   cluster_name   = var.cluster_name
# }