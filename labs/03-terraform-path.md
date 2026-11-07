# Lab 03 — Terraform-owned cluster

## Objective

Read a plan, then apply only that plan, and prove the context name before kubectl.

## Prerequisites

Lab 01. Terraform 1.17.1. [terraform/README.md](../terraform/README.md). Do not start this if `awseks-cli-lab` is the cluster you meant to keep using in the same hour and you do not want a second bill.

## Diagram

[docs/diagrams/01-architecture.svg](../docs/diagrams/01-architecture.svg)

## Commands

Follow [terraform/README.md](../terraform/README.md) through `terraform plan -out=tfplan`. In the plan, confirm:

- `bootstrap_self_managed_addons` is false
- `endpoint_private_access` is true
- `upgrade_policy.support_type` is `STANDARD`
- the node group has no `remote_access`
- NAT count matches `nat_strategy`

Then:

```bash
terraform apply tfplan
aws eks update-kubeconfig --region "$(terraform output -raw region)" \
  --name "$(terraform output -raw cluster_name)" \
  --kubeconfig "./kubeconfig-$(terraform output -raw cluster_name)" \
  --alias "$(terraform output -raw cluster_name)"
export KUBECONFIG="$PWD/kubeconfig-$(terraform output -raw cluster_name)"
kubectl get nodes
```

## Expected observation

Apply finishes with the outputs in `terraform/outputs.tf`. `kubectl config current-context` is `awseks-tf-lab`. Two nodes become `Ready`. `aws eks describe-cluster --query cluster.platformVersion` returns an `eks.N` value chosen by AWS, not by this repo.

## Question

Why is the Helm release absent from the Terraform state after a successful apply?

## Explanation

The controller needs a working API and a service account. Putting a Helm provider in this plan races cluster creation. The IAM role and the Pod Identity association are in state. The chart is the stage script.

## Safe failure

`terraform plan` with `public_access_cidrs = ["0.0.0.0/0"]` and `enable_public_endpoint = true`. The variable validation fails and nothing is created.

## Troubleshooting

[docs/troubleshooting.md](../docs/troubleshooting.md). A node group that never becomes healthy while vpc-cni is still creating is the deadlock the graph is built to avoid. Do not add a dependency from the CNI add-on onto the node group.

## Cost

Full default stack. See [docs/cost.md](../docs/cost.md).

## Cleanup

[docs/cleanup.md](../docs/cleanup.md). Set `deletion_protection = false`, apply, then destroy. Delete load balancers and PVCs first if later labs created them.
