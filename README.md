# k8s-modules
This repository contains live examples for creation of kubernetes cluster which can run env0 deployments.
You can take those examples and use them as-is or fork the repo and adjust for yourself.

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
By default the cluster gets an IAM OIDC provider (IRSA), used only by the EFS CSI driver and the cluster autoscaler. If your security policy forbids creating IAM identity providers, turn it off; those two add-ons then use [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) instead. The env0 agent itself uses neither. Both add-ons are optional too, so a minimal cluster with no storage and no autoscaler is:
```terraform
module "my-cluster" {
  source = "github.com/env0/k8s-modules//aws"

  region       = var.region
  cluster_name = var.cluster_name

  enable_irsa       = false
  enable_efs        = false
  enable_autoscaler = false
}
```
Without EFS, install the agent chart with `env0StateEncryptionKey` set so deployment state is stored encrypted in env0 instead of on a persistent volume.

#### Partial installation
You can also just pick out the parts necessary for your installation.
Check the `versions.tf` of submodule to know which providers are needed, check the `providers.tf` file of the root module to know how to configure them.
 
For example, only create a EFS CSI driver for storage:
```terraform
// csi-driver.tf
module "csi-driver" {
  source = "github.com/env0/k8s-modules//aws/csi-driver"

  cluster_name = "eks_corporation_prod"
  efs_id = var.efs_id
}
```

### Installing the env0 agent
Use env0 provider to create an agent pool and secret, and helm provider to install the agent chart - see [example](https://search.opentofu.org/provider/env0/env0/latest/docs/resources/agent_pool#example-usage).

#### Alternative Log Storage
You can store the deployment logs on your own cloud provider, for supported cloud providers. See `log-storage/README.md` for more details. 

