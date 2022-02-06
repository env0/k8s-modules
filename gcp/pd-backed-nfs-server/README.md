# PD Backed NFS Server
An NFS Server running on K8S, backed by a GCP Regional PD.
To be used for saving the env0 internal state on a persistent disk, which is needed for approve and destroy flows.

## Components
1. `google_compute_region_disk` - A Regional Persistent Disk (PD), replicated to two zones.
1. `pv-for-nfs-server` - A PV which represents the PD (as regional PD's can't be mounted directly to pods)
1. `pvc-for-nfs-server` - The PVC The NFS Server uses. This is bound to the PV using the `storageClassName`.
1. `deployment` - The NFS Server
1. `service` - The Service which exposes the Server 
1. `pv-for-deployment-pods` - The PV that the env0-agent PVC will be bound to, also using `storageClassName`.

## Providers
Requires the `google` and `kubernetes` providers to be configured, see `main.tf` in parent folder.
