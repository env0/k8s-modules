data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "efs" {
  depends_on = [data.aws_eks_cluster.cluster]

  source  = "cloudposse/efs/aws"
  version = "0.32.7"

  region = var.region

  vpc_id  = var.vpc_id
  subnets = var.subnets

  transition_to_ia    = ["AFTER_30_DAYS"]
  
  allowed_security_group_ids = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  
  // NOTE: the module is stupid and puts this tag on the security group and access point as well
  tags = {
    Name = "${var.cluster_name}-state-efs"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = module.efs.id

  backup_policy {
    status = "ENABLED"
  }
}