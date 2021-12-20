data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Private"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = data.aws_subnet_ids.private.ids
  enable_irsa     = true
  vpc_id          = var.vpc_id

  cluster_enabled_log_types = ["api", "scheduler", "controllerManager"] # https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  workers_group_defaults = {
    protect_from_scale_in = true
  }

  node_groups = {
    deployment = {
      desired_capacity = var.min_capacity
      max_capacity     = 50
      min_capacity     = var.min_capacity

      instance_types = [var.instance_type]
      capacity_type  = "SPOT"
    }
  }

  map_roles    = var.map_roles
  map_users    = []
  map_accounts = []
}