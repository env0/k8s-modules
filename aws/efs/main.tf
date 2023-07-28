data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "efs" {
  depends_on = [data.aws_eks_cluster.cluster]

  source  = "cloudposse/efs/aws"
  version = "0.34.0"

  region = var.region

  vpc_id  = var.vpc_id
  subnets = var.subnets

  transition_to_ia    = ["AFTER_7_DAYS"]
  
  enabled = true
  efs_backup_policy_enabled = true

  // NOTE: the module is stupid and puts this tag on the security group and access point as well
  tags = {
    Name = "${var.cluster_name}-state-efs"
  }

  additional_security_group_rules = [
    {
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      cidr_blocks              = []
      source_security_group_id = data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
      description              = "Allow ingress traffic to EFS from primary EKS security group"
    }
  ]
}
