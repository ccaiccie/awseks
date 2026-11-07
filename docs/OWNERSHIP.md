# Who creates what

Two tracks share one cluster. They must not create the same object.

## Terraform track

Stacks 01 through 04. State is the list of what Terraform will delete.

Tagged `Project=awseks-practice` and `ManagedBy=terraform`. IAM roles use path `/awseks-practice/` so `iam:PassRole` can be limited to that path.

Stack 02 is AWS-provider only. It can plan after the network state exists and before any kubeconfig exists.

Stack 03 and stack 04 configure the Kubernetes and Helm providers with `aws eks get-token`. Plan them only after `kubectl get nodes` works. Putting those providers in stack 02 makes Terraform configure a client for an API that the same plan has not created yet. That race is why the stacks are split. HashiCorp documents the same rule for the Kubernetes provider: do not create the cluster and the Kubernetes objects in one module.

## kubectl track

Everything under `manifests/`. Labels include `awseks.practice/owner: student` except where a file is only a fragment.

The labs apply these files. Terraform does not. A later `terraform apply` will not delete them, and it will not refresh them back to a previous spec. You delete them with `scripts/delete-lab-workloads.sh` before `terraform destroy`.

Do not also create, with the AWS CLI or the console:

- a second VPC, cluster, node group, addon, access entry, or Pod Identity association for this name
- a second AWS Load Balancer Controller
- a second EBS CSI driver
- an `aws-auth` ConfigMap. The cluster authentication mode is `API`

The AWS CLI is for read-only checks (`aws sts`, `aws eks describe-cluster`, `aws elbv2 describe-target-health`) and for two optional objects Terraform deliberately does not own: an ACM certificate and a Route 53 record for a domain you control. Clean those up by hand. They are not in state.

## Identity map

| Identity | Where it is created | What it is for |
| --- | --- | --- |
| Lab operator | you, in IAM, before Terraform | human or role that runs Terraform and kubectl |
| Cluster role | stack 02 | the EKS control plane, not kubectl |
| Node role | stack 02 node group | kubelet, ECR pull, and the CNI on the node |
| EBS CSI role | stack 02 Pod Identity | the CSI controller, not the node |
| Load balancer controller role | stack 03 Pod Identity | ALB and NLB resources |
| `lab-pod-identity` | stack 03 | the workload in lab 08 |
| `lab-irsa` | stack 03 | a different workload in lab 08, OIDC, list-only |
| Karpenter controller role | stack 04, optional | launching nodes |
| Karpenter node role | stack 04, optional | the instances Karpenter launches |

RBAC is a second gate. An access entry can allow a principal to reach the API. A RoleBinding decides what that principal can do inside Kubernetes. Lab 07 separates them.

## Tag scope

Cleanup filters on `Project=awseks-practice`. That tag is not a license to delete every tagged resource in the account if another project reused the value. Match the name prefix too. The teardown doc lists the describe commands. It does not include a delete-by-tag script.
