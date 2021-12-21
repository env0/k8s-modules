data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    Tier = "Private"
  }
}

module "efs" {
  source  = "cloudposse/efs/aws"
  version = "0.31.1"

  region = var.region

  vpc_id  = var.vpc_id
  subnets = data.aws_subnet_ids.private.ids

  depends_on = [data.aws_eks_cluster.cluster.vpc_config.cluster_security_group_id]

  transition_to_ia = "AFTER_7_DAYS"

  // NOTE: the module is stupid and puts this tag on the security group and access point as well
  tags = {
    Name = "${var.cluster_name}-state-efs"
  }

  security_group_rules = [
    {
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      cidr_blocks              = []
      source_security_group_id = data.aws_eks_cluster.cluster.vpc_config.cluster_security_group_id
      description              = "Allow ingress traffic to EFS from primary EKS security group"
    },
    {
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      cidr_blocks              = []
      source_security_group_id = data.aws_eks_cluster.cluster.vpc_config.cluster_security_group_id
      description              = "Allow ingress traffic to EFS from additional EKS security group"
    }
  ]
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = module.efs.id

  backup_policy {
    status = "ENABLED"
  }
}