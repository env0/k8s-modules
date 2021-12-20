# k8s-modules

### AWS 
#### Full-blown install
```terraform
module "my-cluster" {
  source = "git::github.com:env0/k8s-modules.git//aws"

  cluster_name = 'env0_cluster'
}
```
#### Specific module - see AWS folder for other modules 
```terraform
module "csi-driver" {
  source = "git::github.com:env0/k8s-modules.git//aws/csi-driver"

  cluster_name = 'env0_cluster'
  efs_id = <id>
}
```