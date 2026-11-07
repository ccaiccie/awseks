# Lab 19 — Teardown

## Objective

Delete load balancers and volumes first, then controllers, nodes, the cluster, and the VPC. Confirm the tagged leftovers.

## Architecture

Finalizers point from Kubernetes objects at AWS objects. The controller that removes the AWS object is the same controller that clears the finalizer. Order matters. [docs/CLEANUP.md](../docs/CLEANUP.md) is the procedure this lab follows.

## Prerequisites

You are done with the other labs. The kubectl context name contains the cluster name.

## Steps

```bash
./scripts/teardown-checklist.sh
CONFIRM=delete-lab-workloads CLUSTER_NAME="$CLUSTER_NAME" ./scripts/delete-lab-workloads.sh
kubectl get svc,ingress,pvc -A
```

`lab-identity` is in that delete list even though Terraform created it. Stack 03 destroy expects it to be gone or deletes it again. Do not delete `kube-system`.

When no LoadBalancer Service or Ingress remains:

```bash
terraform -chdir=terraform/stacks/04-karpenter destroy   # skip if you never enabled it
terraform -chdir=terraform/stacks/03-platform destroy
terraform -chdir=terraform/stacks/02-cluster destroy
terraform -chdir=terraform/stacks/01-network destroy
```

Each destroy prints a plan. Read it. If stack 02 refuses because deletion protection is on, set `cluster_deletion_protection = false`, apply, and destroy again.

Then the residual checks from `docs/CLEANUP.md`:

```bash
aws ec2 describe-nat-gateways --filter Name=tag:Project,Values=awseks-practice --query 'NatGateways[].State'
aws ec2 describe-addresses --filters Name=tag:Project,Values=awseks-practice
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName'
aws ec2 describe-volumes --filters Name=status,Values=available Name=tag:Project,Values=awseks-practice
```

## Expected observations

Example only. The workload script exits 0 and the namespaces are gone. Stack 04's plan is empty if you never set the confirmation. Stack 01's destroy plan contains the NAT gateway. After destroy, the NAT query returns an empty list or `deleted`. `describe-load-balancers` might still show load balancers that are not this class. Read the names. Do not delete those.

The KMS key remains pending deletion for 7 days.

## Questions

1. What is still billed after the cluster is gone if you skip stack 01?
2. Why is there no `delete-by-tag` script?
3. A namespace is stuck `Terminating` and the controller Deployment is already gone. What AWS object do you look for?

## Failure injection

None. A stuck finalizer is the failure. Practice the recovery in `docs/CLEANUP.md` if you hit one. Do not patch finalizers until the AWS object is confirmed gone, or the load balancer becomes invisible to Kubernetes and keeps billing.

## Diagnostics

Destroy of the node group waits on a PDB or a volume attachment. `kubectl get pdb,pvc -A` before stack 02 destroy. If the API is already unreachable, use the AWS CLI volume and load balancer describes, filtered by the project tag and the name prefix.

## Answers

1. The NAT gateway, its public IPv4, and any interface endpoints or flow log groups. Those are stack 01. EBS volumes with a Retain policy and the KMS key are the other leftovers.
2. A tag match across an account deletes someone else's resources when they reused the tag, and it deletes resources this class does not own. The describes are filtered so a person can read them.
3. A load balancer or an EBS volume tagged `Project=awseks-practice` whose name contains the cluster or the PVC. Delete that AWS object, then remove the finalizer if the namespace still will not leave.

## Cleanup

This lab is the cleanup.

## Cost

The bill stops when the NAT gateway, EIPs, load balancers, nodes, cluster, endpoints, and available volumes are gone. Cost Explorer lags. The describe calls are the check you can do the same day. Extended-support pricing does not apply to a deleted cluster.
