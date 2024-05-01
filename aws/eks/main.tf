locals {
  managed_node_group_name = "deployment"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  enable_irsa     = true

  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids


  # https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  cluster_enabled_log_types = ["api", "scheduler", "controllerManager"]

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  eks_managed_node_groups = {
    deployment = {
      use_name_prefix = false
      name            = local.managed_node_group_name
      desired_size    = var.min_capacity
      max_size        = 50
      min_size        = var.min_capacity

      instance_types = [var.instance_type]
      capacity_type  = "SPOT"
    }
  }

  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  create_kms_key          = false
  enable_kms_key_rotation = false
  cluster_encryption_config = {}

}
