# Lab 15 — Karpenter, optional and separate

## Objective

Install Karpenter only for this lab, with a chart version the compatibility matrix allows, and keep it out of the default cluster.

## Architecture

Karpenter is a controller pod with its own IAM role. It launches EC2 instances using a different node role, and stack 04 creates an access entry so those instances can join an `API` authentication cluster. The interruption queue is for spot. The sample NodePool is on-demand `t3.medium` and limits the pool to 2 vCPU, so it cannot replace the whole class cluster by surprise.

Compatibility, retrieved 2026-11-07 from https://karpenter.sh/docs/upgrading/compatibility/ :

| Kubernetes | Karpenter |
| --- | --- |
| 1.35 | >= 1.9 |
| 1.36 | >= 1.13 |
| 1.37 | 1.15.x |

The stack pins chart `1.15.1`, which is also the version in the upstream getting-started sample. It refuses a different version unless you set `allow_untested_karpenter_version`. Do not pair an older chart you copied from another repo with 1.36 or 1.37.

Upstream asks for 1 CPU and 1Gi. This stack requests 100m and 256Mi so a t3.medium still has room. Raise it if the controller throttles.

## Prerequisites

Stacks 01 and 02. Decide the cost out loud. Then:

```bash
# terraform/stacks/04-karpenter/terraform.tfvars
enable_karpenter        = true
karpenter_confirmation  = "enable-karpenter"
```

```bash
terraform -chdir=terraform/stacks/04-karpenter plan
terraform -chdir=terraform/stacks/04-karpenter apply
kubectl -n kube-system rollout status deploy/karpenter
```

## Steps

```bash
terraform -chdir=terraform/stacks/04-karpenter output
```

Edit `manifests/lab15-karpenter/nodepool.yaml`. Set `role` to the node role name, not the controller role. Set `aws:eks:cluster-name` and `NamePrefix` to the cluster name. The subnet selector uses the tags stack 01 already applied.

```bash
kubectl apply -f manifests/lab15-karpenter/nodepool.yaml
kubectl get nodepool,ec2nodeclass
kubectl describe nodepool lab
```

Do not scale a workload onto it unless you want a new instance. The pool limit is 2 vCPU. A single t3.medium is that entire budget.

## Expected observations

Example only. The Helm release is deployed. `kubectl get nodepool` shows `lab` and the NodeClass is Ready. No extra EC2 instance exists until a pod cannot schedule on the managed group and the NodePool accepts it. `terraform state list` in stack 04 does not contain the NodePool. That object is yours.

## Questions

1. Why is the NodePool not a Terraform resource in stack 04?
2. Which role would be wrong in `spec.role`?
3. What happens to a 1.36 cluster if someone installs Karpenter 1.12 because another blueprint pinned it?

## Failure injection

Optional. Taint the managed nodes and create one pending pod that tolerates nothing except the Karpenter label, then watch a node appear. Delete that pod and confirm consolidation removes the node after `consolidateAfter`. This spends instance time. Skip it if the room only needed to read the manifest.

## Diagnostics

Helm error on CRDs: the chart version and the Kubernetes version do not match the matrix. NodeClass not Ready: the role name is the controller role, or the subnet tags do not match. Instance never joins: the access entry was disabled. `kubectl logs -n kube-system deploy/karpenter`.

## Answers

1. The CRDs arrive with the Helm release. A NodePool in the same Terraform plan races that CRD. Keeping the manifest in kubectl also makes the ownership obvious: Terraform will not refresh it away while you edit requirements.
2. The controller role. `spec.role` is the instance role. The output `karpenter_node_role_arn` is the one whose name you copy. The controller role cannot be an EC2 instance profile.
3. The compatibility page lists 1.36 as requiring Karpenter >= 1.13. 1.12 is outside that range. The stack exists so the class does not inherit an unrelated pin.

## Cleanup

```bash
kubectl delete -f manifests/lab15-karpenter/nodepool.yaml
terraform -chdir=terraform/stacks/04-karpenter destroy
```

Confirm any Karpenter-launched instance is terminated before you leave. The managed node group is still there. Do not destroy stack 02 as part of this lab.

## Cost

The controller pod is free beyond the nodes it runs on. Each instance the NodePool launches is an EC2 bill. The queue is cheap. The confirmation string is what keeps this off the default apply.
