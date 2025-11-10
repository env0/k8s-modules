locals {
  managed_node_group_name = "deployment_v2"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.4"

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
    ami_type = "AL2023_x86_64_STANDARD"

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
    deployment_v2 = {
      version = var.kubernetes_version

      name            = "deployment_v2"
      use_name_prefix = false

      min_size     = var.min_capacity
      desired_size = var.min_capacity
      max_size     = var.max_capacity

      update_config = {
        max_unavailable_percentage = 50
      }

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
    }
  }

  cluster_addons = {
    coredns = {
      preserve = true
      addon_version = var.coredns_version

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      addon_version = var.kube_proxy_version
    }
    vpc-cni    = {
      addon_version = var.vpc_cni_version
    }
  }

  create_kms_key            = false
  enable_kms_key_rotation   = false
  cluster_encryption_config = {}
}
