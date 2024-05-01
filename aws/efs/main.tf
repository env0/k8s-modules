module "efs" {

  source  = "cloudposse/efs/aws"
  version = "~> 1.1"

  region = var.region

  name = "${var.cluster_name}-state-efs"

  vpc_id  = var.vpc_id
  subnets = var.subnets

  transition_to_ia = ["AFTER_7_DAYS"]

  enabled                   = true
  efs_backup_policy_enabled = true

  allowed_security_group_ids = var.allowed_security_group_ids
}
