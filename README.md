# k8s-modules
This repository contains live examples for creation of kubernetes cluster which can run env0 deployments.
you can take those examples and use them as-is or fork the repo and adjustment for yourself.

you can build mix of the modules (csi-driver) if you liked

### AWS 
#### providers.tf
```terraform
provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}
```
#### cluster.tf
Full-blown install
```terraform
module "my-cluster" {
  source = "github.com/env0/k8s-modules//aws"

  region       = var.region
  cluster_name = var.cluster_name
}
``` 
#### csi-driver.tf
Specific module - see AWS folder for other modules
```terraform
module "csi-driver" {
  source = "github.com/env0/k8s-modules//aws/csi-driver"

  cluster_name = 'eks_corporation_prod'
  efs_id = var.efs_id
}
```
#### agent.tf
```terraform
resource "helm_release" "agent" {
  depends_on       = [module.my-cluster] // add all dependency 
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