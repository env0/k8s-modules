locals {
  managed_node_group_name = "deployment"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  enable_irsa = true

  enable_cluster_creator_admin_permissions = true

  access_entries = var.cluster_access_entries

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids


  # https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  cluster_enabled_log_types = ["api", "scheduler", "controllerManager"]

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          delete_on_termination = true
        }
      }
    }
  }

  eks_managed_node_groups = {
    deployment = {
      version = var.kubernetes_version

      name            = local.managed_node_group_name
      use_name_prefix = false

      min_size     = var.min_capacity
      desired_size = var.min_capacity
      max_size     = 50

      update_config = {
        max_unavailable_percentage = 50
      }

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
    }
  }

  cluster_addons = {
    coredns = {
      version    = "v1.11.1-eksbuild.9"
      preserve    = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      version = "v1.29.3-eksbuild.5"
    }
    vpc-cni = {
      version = "v1.18.2-eksbuild.1"
    }
  }

  create_kms_key            = false
  enable_kms_key_rotation   = false
  cluster_encryption_config = {}
}
