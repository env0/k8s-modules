# k8s-modules
This repository contains live examples for creation of kubernetes cluster which can run env0 deployments.
you can take those examples and use them as-is or fork the repo and adjust for yourself.

You can, of course, mix and match according to your own needs.

### AWS 
#### Creating a full-blown cluster installation
If you'd like to create a cluster from scratch, including a VPC and an EFS for storage, you can simply use the `aws` root folder as a module.
```terraform
// cluster.tf
module "my-cluster" {
  source = "github.com/env0/k8s-modules//aws"

  region       = var.region
  cluster_name = var.cluster_name
}
``` 
#### Partial installation
You can also just pick out the parts necessary for your installation.
Check the `versions.tf` of submodule to know which providers are needed, check the `providers.tf` file of the root module to know how to configure them.
 
For example, only create a EFS CSI driver for storage:
```terraform
// csi-driver.tf
module "csi-driver" {
  source = "github.com/env0/k8s-modules//aws/efs-csi-driver"

  cluster_name = "eks_corporation_prod"
  efs_id = var.efs_id
}
```

#### Alternative Log Storage
You can store the deployment logs on your own cloud provider, for supported cloud providers. See `log-storage/README.md` for more details
### Installing the env0 agent
If you'd like, you can also install the env0 agent using terraform.
Make sure you fill out 
* `var.env0_values` according to the values provided to you by env0
* `var.customer_values` according to your features [optional configuration](https://docs.env0.com/docs/self-hosted-kubernetes-agent#customoptional-configuration) 
```terraform
// agent.tf
resource "helm_release" "agent" {
  depends_on       = [module.my-cluster] // add all necessary dependencies here 
  name             = "env0-agent"
  namespace        = "env0-agent"
  chart            = "env0-agent"
  create_namespace = true
  repository       = "https://env0.github.io/self-hosted"
  timeout          = 600
  values           = [
    yamlencode(merge(jsondecode(var.env0_values), jsondecode(var.customer_values)))
  ]
}
```
