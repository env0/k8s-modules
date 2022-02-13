# GCP Resources for the env0 self hosted agent

This stack is a reference example for prerequsites needed to deploy an env0 deployment agent to an existing GKE cluster.  

## NFS Server and Provisioner
Using [nfs-ganesha-server-and-external-provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/tree/master/charts/nfs-server-provisioner), which is an out-of-tree dynamic provisioner for Kubernetes 1.14+.    
It is used quickly & easily deploy shared storage that works almost anywhere.  

We will use it for saving the env0 internal state on a persistent disk, which is needed for approve and destroy flows.  


## Configuration
We use its [Helm chart](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/tree/master/charts/nfs-server-provisioner)  with a [persistence configuration](https://github.com/env0/k8s-modules/pull/14/files#diff-09e408310fbc02dc53a3f7d05327dc6ff2ff999178ca1f6c305f5cfa4474540cR7) that adds a K8s [annotation](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/blob/master/charts/nfs-server-provisioner/templates/storageclass.yaml#L13) that will:

> _"On many clusters, the cloud provider integration will create a "standard" storage class which will create a volume (e.g. **a Google Compute Engine Persistent Disk** or Amazon EBS volume) to provide persistence."_
[source](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/tree/master/charts/nfs-server-provisioner#recommended-persistence-configuration-examples)  


See [here](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner/tree/master/charts/nfs-server-provisioner#recommended-persistence-configuration-examples) for more configuration examples.  

## Providers
Requires the `google` and `kubernetes` and `helm` providers to be configured.  
