data "aws_eks_node_group" "nodegroup" {
  cluster_name = var.cluster_name
  node_group_name = "${var.cluster_name}-deployment" # this creates coupling between eks node_group_name to efs, but it's not an issue ATM
}

module "efs" {
  depends_on = [data.aws_eks_node_group.nodegroup]

  source  = "cloudposse/efs/aws"
  version = "0.34.0"

  region = var.region

  vpc_id  = var.vpc_id
  subnets = var.subnets

  transition_to_ia    = ["AFTER_7_DAYS"]
  
  enabled = true
  efs_backup_policy_enabled = true
  
  associated_security_group_ids = [data.aws_eks_node_group.nodegroup.resources[0].remote_access_security_group_id]

  // NOTE: the module is stupid and puts this tag on the security group and access point as well
  tags = {
    Name = "${var.cluster_name}-state-efs"
  }
}
