module "auth_config" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.8"

  manage_aws_auth_configmap = true
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users            = []
  aws_auth_accounts         = []
}