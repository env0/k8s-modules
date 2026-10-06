# k8s-modules

Terraform modules that provision a Kubernetes cluster for the [env zero self-hosted agent](https://docs.envzero.com/guides/admin-guide/self-hosted-kubernetes-agent/overview).
Use them as-is, pick single submodules, or fork the repository and adjust them.

| Folder | What it creates |
|---|---|
| [`aws`](aws) | A full EKS stack: VPC, EKS cluster, cluster autoscaler, and optional EFS storage and Calico |
| [`aws/<submodule>`](aws) | One part of the AWS stack: `vpc`, `eks`, `autoscaler`, `efs`, `csi-driver`, `calico` |
| [`gcp`](gcp) | NFS storage prerequisites for the agent on an existing GKE cluster |
| [`log-storage/aws/dynamodb`](log-storage/aws/dynamodb) | DynamoDB tables for [hosting the deployment logs](https://docs.envzero.com/guides/admin-guide/self-hosted-kubernetes-agent/hosting-the-deployment-logs) in your AWS account |

## Versioning

Pin every module source to a release tag with `?ref=<tag>`.
Use the [latest release](https://github.com/env0/k8s-modules/releases/latest).
The examples below use `v1.2.0`.

## Bootstrap a self-hosted agent on AWS

The example creates an EKS cluster, an agent pool in env zero, an agent secret, and installs the agent Helm chart.
The agent stores the deployment state and working directory with [env zero-hosted encrypted state](https://docs.envzero.com/guides/admin-guide/self-hosted-kubernetes-agent/env-zero-hosted-encrypted-state), so the cluster needs no EFS or persistent volume.

### Prerequisites

- Terraform >= 1.3 or OpenTofu.
- AWS credentials that can create a VPC, EKS, IAM roles and Auto Scaling settings.
- AWS CLI v2 and `bash` on the machine that runs Terraform. The providers use `aws eks get-token`, and the `autoscaler` submodule runs `aws autoscaling` commands.
- An env zero organization API key, set in `ENV0_API_KEY` and `ENV0_API_SECRET`. See [API keys](https://docs.envzero.com/guides/admin-guide/user-role-and-team-management/api-keys).

### Example

```terraform
terraform {
  required_providers {
    env0 = {
      source  = "env0/env0"
      version = "~> 1.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0, < 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "env0-agent"
}

module "cluster" {
  source = "github.com/env0/k8s-modules//aws?ref=v1.2.0"

  region       = var.region
  cluster_name = var.cluster_name

  # The agent uses env zero-hosted encrypted state, so no EFS is needed
  create_efs_storage = false
}

provider "env0" {}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name, "--region", var.region]
    }
  }
}

resource "env0_agent_pool" "this" {
  name = var.cluster_name
}

resource "env0_agent_secret" "this" {
  agent_id = env0_agent_pool.this.id
}

# Encrypts the state and working directory before the agent uploads them.
# Changing this value later loses the local state of existing environments.
resource "random_password" "state_encryption_key" {
  length  = 32
  special = false
}

resource "helm_release" "env0_agent" {
  repository = "https://env0.github.io/self-hosted"
  chart      = "env0-agent"

  name             = "env0-agent"
  namespace        = "env0-agent"
  create_namespace = true
  timeout          = 600

  set_sensitive {
    name  = "agentAccessToken"
    value = env0_agent_secret.this.secret
  }

  set_sensitive {
    name  = "env0StateEncryptionKey"
    value = base64encode(random_password.state_encryption_key.result)
  }
}
```

Run it:

```bash
terraform init
terraform apply
```

The apply usually takes 15 to 25 minutes. Most of the time goes to the EKS cluster and node group.
After the apply, the agent pool shows in env zero under **Organization Settings** > **Agents**.

### Assign the agent to a project

```terraform
resource "env0_agent_project_assignment" "this" {
  agent_id   = env0_agent_pool.this.id
  project_id = "<project-id>"
}
```

### Use EFS for the agent state instead

Some organizations must keep the state and working directory in their own AWS account.
For that, keep the default `create_efs_storage = true` and remove the `env0StateEncryptionKey` block and the `random_password` resource.
The module then creates an EFS file system, the EFS CSI driver, and the `env0-state-sc` StorageClass that the agent chart uses for its persistent volume.

### Next steps

- [Custom/optional configuration](https://docs.envzero.com/guides/admin-guide/self-hosted-kubernetes-agent/custom-optional-configuration): add Helm values to `helm_release.env0_agent`.
- [Authenticating the agent on AWS EKS](https://docs.envzero.com/guides/admin-guide/self-hosted-kubernetes-agent/authenticating-the-agent-on-aws-eks): give deployments an IAM role. The `oidc_provider_arn` output feeds the IAM role trust policy.

## `aws` module reference

### Inputs

| Name | Default | Description |
|---|---|---|
| `cluster_name` | (required) | Name of the EKS cluster. Also used to name the VPC, EFS and IAM roles |
| `region` | `us-east-1` | AWS region |
| `kubernetes_version` | `1.35` | EKS Kubernetes version |
| `cluster_autoscaler_chart_version` | `9.59.0` | cluster-autoscaler Helm chart version. Change it when you change `kubernetes_version`, see below |
| `create_efs_storage` | `true` | Create EFS, the EFS CSI driver and the `env0-state-sc` StorageClass |
| `reclaim_policy` | `Retain` | Reclaim policy of the `env0-state-sc` StorageClass |
| `min_capacity` / `max_capacity` | `2` / `20` | Node group size limits |
| `instance_types` | `t3a.2xlarge`, `t3a.xlarge`, `t3.2xlarge`, `t3.xlarge` | Node instance types |
| `capacity_type` | `SPOT` | `SPOT` or `ON_DEMAND` |
| `cluster_access_entries` | `{}` | Extra EKS access entries |
| `coredns_version` / `kube_proxy_version` / `vpc_cni_version` | `null` | EKS addon versions. `null` uses the EKS default for `kubernetes_version` |
| `azs`, `cidr`, `private_subnets_cidr_blocks`, `public_subnets_cidr_blocks` | see [`aws/variables.tf`](aws/variables.tf) | VPC layout |
| `enable_calico` / `calico_docker_hub_credentials` | `false` / `null` | Install Calico for network policy enforcement |

### Outputs

| Name | Description |
|---|---|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | EKS API server endpoint |
| `cluster_certificate_authority_data` | Base64 cluster CA certificate |
| `oidc_provider_arn` | ARN of the cluster OIDC provider, for IAM roles for service accounts |

### Kubernetes and autoscaler versions

The cluster-autoscaler minor version must match the Kubernetes minor version.
Chart `9.59.0` ships cluster-autoscaler `1.35`.
If you set another `kubernetes_version`, set `cluster_autoscaler_chart_version` to a chart for that minor version:

```bash
helm search repo autoscaler/cluster-autoscaler --versions
```

Run `helm repo add autoscaler https://kubernetes.github.io/autoscaler` first.

### Upgrade from v1.1.0

- `kubernetes_version`, `coredns_version`, `kube_proxy_version` and `vpc_cni_version` are now optional. Keep passing them to keep your current versions.
- The EFS submodules moved to `module.efs[0]` and `module.efs_csi_driver[0]`. `moved` blocks handle the move. Expect no EFS changes in the plan.
- The cluster-autoscaler chart moved from `9.33.0` to `9.59.0`. Set `cluster_autoscaler_chart_version` if your cluster is not on Kubernetes 1.35.

## Use a single submodule

Each submodule lists its providers in its `versions.tf`. See [`aws/providers.tf`](aws/providers.tf) for how to configure them.

For example, to create only the EFS CSI driver and StorageClass:

```terraform
module "csi_driver" {
  source = "github.com/env0/k8s-modules//aws/csi-driver?ref=v1.2.0"

  cluster_name      = "my-cluster"
  efs_id            = var.efs_id
  oidc_provider_arn = var.oidc_provider_arn
}
```

## GCP

The [`gcp`](gcp) folder installs an NFS server provisioner on an existing GKE cluster, for the agent persistent volume. See [`gcp/README.md`](gcp/README.md).
With env zero-hosted encrypted state, the agent needs no persistent volume, so you can skip this folder.

## Deployment log storage

To keep the deployment logs in your own AWS account, see [`log-storage/README.md`](log-storage/README.md).
