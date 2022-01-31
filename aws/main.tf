
module "my_vpc" {
  source = "github.com/env0/k8s-modules//aws/vpc?ref=chore-add-modules-params"

  cluster_name    = var.cluster_name
}
