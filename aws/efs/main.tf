module "efs" {

  source  = "cloudposse/efs/aws"
  version = "0.34.0"

  region = var.region

  vpc_id  = var.vpc_id
  subnets = var.subnets

  transition_to_ia = ["AFTER_7_DAYS"]

  enabled                   = true
  efs_backup_policy_enabled = true
  
  allowed_security_group_ids = var.allowed_security_group_ids

  // NOTE: the module is stupid and puts this tag on the security group and access point as well
  tags = {
    Name = "${var.cluster_name}-state-efs"
  }
}
