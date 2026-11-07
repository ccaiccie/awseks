# Terraform path

This directory owns cluster `awseks-tf-lab` (or another name that matches `^awseks-tf-[a-z0-9-]{1,24}$`). The AWS CLI path must not adopt it.

Kubernetes and Helm providers are not in this stack. A provider that reads the API during the same plan as cluster creation races the API, the access entry, and the CNI. Add-ons here are `aws_eks_addon`. The load balancer controller is [../stages/aws-load-balancer-controller/install.sh](../stages/aws-load-balancer-controller/install.sh) after kubeconfig works.

## Before apply

Read [../docs/cost.md](../docs/cost.md). Copy the example and set a real region:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` is gitignored. Leave `enable_public_endpoint` false if you will call the API from inside the VPC. To use a laptop, set:

```hcl
enable_public_endpoint = true
public_access_cidrs    = ["203.0.113.10/32"] # replace with the /32 from checkip.amazonaws.com
```

`203.0.113.10/32` is rejected on purpose. `0.0.0.0/0` is rejected. Discover the address with:

```bash
curl -fsS https://checkip.amazonaws.com
```

Do not commit that address.

## Commands

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
```

`init` writes `.terraform/` (gitignored) and uses `.terraform.lock.hcl` (committed). `validate` does not contact AWS. `plan` does. Read the plan. You should see one VPC, public and private subnets, one NAT when `nat_strategy` is `single`, an S3 gateway endpoint, IAM roles, one EKS cluster, one launch template, one managed node group, and the add-ons. You should not see SSH keys, `0.0.0.0/0` as an API allow list, or an Auto Mode `compute_config`.

The plan prints `resolved_addon_versions`. Pod Identity Agent and EBS CSI versions come from the default `aws_eks_addon_version` data source. If a pinned vpc-cni, kube-proxy, or CoreDNS version is rejected by AWS, stop and update [../docs/versions.md](../docs/versions.md). Do not flip `most_recent` on those three to hide a stale pin.

Apply the file you reviewed:

```bash
terraform apply tfplan
```

There is no apply in CI and none was run to produce this repository.

## Kubeconfig

```bash
aws eks update-kubeconfig \
  --region "$(terraform output -raw region)" \
  --name "$(terraform output -raw cluster_name)" \
  --kubeconfig "./kubeconfig-$(terraform output -raw cluster_name)" \
  --alias "$(terraform output -raw cluster_name)"
export KUBECONFIG="$PWD/kubeconfig-$(terraform output -raw cluster_name)"
kubectl config current-context
kubectl get nodes
```

Expected context name: `awseks-tf-lab`. Expected nodes: two `Ready` lines after the node group and vpc-cni are active. A timeout here is usually the public endpoint, not a missing node. See [../docs/troubleshooting.md](../docs/troubleshooting.md).

## State

Default state is local `terraform.tfstate`, gitignored. `backend.tf.example` shows an S3 backend and a DynamoDB lock. It is not active. Copy it only if you want shared state, and do not commit the filled file. Deletion protection defaults to true. Destroy steps are in [../docs/cleanup.md](../docs/cleanup.md).

## What you should not change in the same apply

- Do not add the `kubernetes` or `helm` provider to this directory.
- Do not set `bootstrap_self_managed_addons` back to true while the managed add-ons exist.
- Do not add `depends_on = [aws_eks_node_group.default]` to `aws_eks_addon.vpc_cni`.
- Do not set `vpc_cni_use_pod_identity` on the first apply.
