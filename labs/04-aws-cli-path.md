# Lab 04 — AWS CLI-owned cluster

## Objective

Build the same shape without Terraform, and keep its state file separate.

## Prerequisites

Lab 01. Do not set `CLUSTER_NAME` to the Terraform cluster. Copy `cli/config.env.example` to `cli/config.env`.

## Diagram

[docs/diagrams/01-architecture.svg](../docs/diagrams/01-architecture.svg) and the command list in [docs/cli-walkthrough.md](../docs/cli-walkthrough.md).

## Commands

```bash
cli/bin/00-preflight.sh
cli/bin/10-network.sh
cli/bin/20-iam.sh
cli/bin/30-cluster.sh
cli/bin/40-nodegroup.sh
cli/bin/50-addons.sh
cli/bin/60-access.sh
cli/bin/70-kubeconfig.sh
cli/bin/80-verify.sh
```

Or `cli/bin/provision.sh` and type `provision awseks-cli-lab`.

## Expected observation

`cli/state/checkpoints.log` gains `preflight`, `vpc`, `cluster-active`, `nodes-and-networking-active`, `verify-ok`. `KUBECONFIG=cli/state/kubeconfig` and the context is `awseks-cli-lab`. `Provisioner` on the cluster is `awscli`.

## Question

Why does `40-nodegroup.sh` create vpc-cni before it returns, instead of waiting for the node group first?

## Explanation

The node group becomes ACTIVE when nodes are Ready enough for EKS to finish. Nodes stay NotReady until the CNI programs them. The add-on stays degraded until a node exists. Creating both and waiting in `50-addons.sh` is the order that finishes. CoreDNS waits until after that, because it is a Deployment and needs a Ready node.

## Safe failure

Set `CLUSTER_NAME=awseks-tf-lab` in `config.env` and run preflight. The name check exits before any AWS create.

## Troubleshooting

IAM `PassRole` errors happen at `30-cluster.sh`, not at kubeconfig. Version errors happen at `40` or `50` and mean the pin and the live API disagree.

## Cost

Same default shape as the Terraform path. A second cluster doubles it.

## Cleanup

`cli/bin/90-cleanup.sh` after you type `delete awseks-cli-lab`. Read [docs/cleanup.md](../docs/cleanup.md) first.
