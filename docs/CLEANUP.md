# Cleanup

Destroy in this order. `scripts/teardown-checklist.sh` prints the same list and does not delete anything. No workflow runs destroy.

## 1. Student load balancers, ingresses, and volumes

```bash
CONFIRM=delete-lab-workloads CLUSTER_NAME=eks-lab ./scripts/delete-lab-workloads.sh
```

The script checks that the current kubectl context contains the cluster name, deletes the lab namespaces, and waits up to 10 minutes. It does not touch `kube-system`.

A namespace stays in `Terminating` when:

- a Service of type LoadBalancer still has a finalizer `service.k8s.aws/resources` because the controller has not deleted the NLB
- an Ingress finalizer is waiting on the ALB
- a PVC finalizer is waiting on an EBS volume

Watch `kubectl describe` on the object. Wait for the AWS load balancer to disappear before you delete the controller. If you delete the controller first, the finalizer never completes and the namespace sticks. The fix is to remove the leftover load balancer in the AWS console only if it is tagged `Project=awseks-practice` and the name contains the cluster, then delete the finalizer as a last resort. A stuck finalizer is how volumes and load balancers become untracked bills.

EFS persistent volumes in the opt-in file use `Retain`. Deleting the PVC does not delete the file system. Stack 03 destroy does, if you opted in and the file system is still in state.

## 2. Terraform, from the top of the stack

```bash
terraform -chdir=terraform/stacks/04-karpenter destroy   # only if you enabled it
terraform -chdir=terraform/stacks/03-platform destroy
terraform -chdir=terraform/stacks/02-cluster destroy
terraform -chdir=terraform/stacks/01-network destroy
```

Review every plan. Stack 02 will not delete the cluster if `cluster_deletion_protection` is true. Set it to false, apply, then destroy.

The KMS key waits 7 days after destroy. It keeps the small monthly charge until AWS finishes the deletion window.

## 3. Objects Terraform never owned

- ACM certificates and Route 53 records from lab 12
- a Pod Identity agent version you pinned only in tfvars is in state; you do not delete it separately
- local `terraform.tfstate` and kubeconfig entries on your laptop

## 4. Prove the bill stopped

```bash
aws ec2 describe-nat-gateways --filter Name=tag:Project,Values=awseks-practice --query 'NatGateways[].State'
aws ec2 describe-addresses --filters Name=tag:Project,Values=awseks-practice
aws elbv2 describe-load-balancers --query 'LoadBalancers[].{Name:LoadBalancerName,State:State.Code}'
aws ec2 describe-volumes --filters Name=status,Values=available Name=tag:Project,Values=awseks-practice
```

An available EBS volume tagged for this project is a leftover disk. Delete that volume. Do not delete untagged volumes. `describe-load-balancers` is account-wide in the Region. Read the names before you delete anything. There is no script in this repo that deletes by tag.

Cost Explorer is delayed. An empty describe result is the useful check on the day. A zero in Cost Explorer tomorrow is the confirmation.

## Failure recovery

| Symptom | What to do |
| --- | --- |
| `terraform apply` failed halfway through the cluster | Run `terraform plan` again. Let it finish the same stack. Do not start stack 03. |
| Nodes never become Ready | `kubectl describe node` and the aws-node logs. Private subnets need the NAT route or the interface endpoints from lab 11. The node security group must allow the cluster to talk to the kubelet. |
| Public API times out | Your CIDR changed. Update `endpoint_public_access_cidrs` and apply. Do not open the world. |
| AccessDenied on `iam:PassRole` | The caller policy is missing PassRole, or the role path is not `/awseks-practice/`. |
| Addon create conflict | The stacks set `resolve_conflicts_on_create` to `OVERWRITE` for the class add-ons. If you also installed the same addon with the CLI, delete that CLI addon before the next apply. |
| Destroy stuck on the node group | A PodDisruptionBudget in kube-system or a volume attachment can block. Delete student PVCs first. `kubectl get pdb -A`. |
| Namespace Terminating after the controller is gone | Find the tagged load balancer or volume, delete the AWS object, then clear the finalizer. |

State is local. If you lose `terraform.tfstate`, Terraform will try to create a second cluster of the same name and fail, or worse, drift. Restore the state file from the machine that applied. Do not import random account resources to "fix" it during class.
