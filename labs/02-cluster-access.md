# Lab 02 — API endpoint and access entries

## Objective

Reach the API with your principal, and see a node join without opening the API to the world.

## Architecture

The IAM/RBAC figure in [docs/DIAGRAMS.md](../docs/DIAGRAMS.md). This lab is only the AWS half: the access entry. RBAC comes in lab 07.

## Prerequisites

Stack 02 applied. `admin_principal_arns` contains the ARN from `aws sts get-caller-identity`, not the account root.

If the public endpoint is off, run the kubectl commands from a network that can route to the private endpoint. A laptop on the internet cannot. Either use a client inside the VPC, or set a `/32` and apply before this lab. The plan must not contain `0.0.0.0/0`.

## Steps

```bash
aws sts get-caller-identity
aws eks describe-cluster --name "$CLUSTER_NAME" \
  --query 'cluster.{version:version,public:resourcesVpcConfig.endpointPublicAccess,private:resourcesVpcConfig.endpointPrivateAccess,cidrs:resourcesVpcConfig.publicAccessCidrs,auth:accessConfig.authenticationMode}'
aws eks list-access-entries --cluster-name "$CLUSTER_NAME"
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get ds -n kube-system
```

## Expected observations

Example only.

```text
public False
private True
auth API
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-1-12.ec2.internal     Ready    <none>   8m    v1.35.x
ip-10-0-40-20.ec2.internal    Ready    <none>   8m    v1.35.x
```

`kube-system` contains `aws-node`, `kube-proxy`, `coredns`, and `eks-pod-identity-agent` pods. CoreDNS is a Deployment. The others are DaemonSets. There is no `aws-auth` ConfigMap to edit.

## Questions

1. Why does `enable_cluster_creator_admin_permissions` stay false?
2. What does hop limit 1 on the instance metadata service change for a pod?
3. Which addon is allowed to use `most_recent`, and why is that the exception?

## Failure injection

Optional, and only with a second IAM principal that is not in `admin_principal_arns`. `aws eks update-kubeconfig` as that principal, then `kubectl get nodes`. Do not remove your own access entry.

## Diagnostics

`kubectl` timeout with a public endpoint means the CIDR no longer matches your address. `error: You must be logged in` or an IAM message means the access entry principal does not match the caller. `Unauthorized` after a successful STS call means the access policy association is missing. Nodes `NotReady` with a CNI crash usually mean the private subnet has no default route. Go back to lab 01.

## Answers

1. The creator would become a cluster admin implicitly. The class lists the principal in tfvars so the grant is reviewed. The person who runs Terraform still has to be on that list, or their kubectl calls fail.
2. Pods are a second network hop from IMDS. Hop limit 1 lets the kubelet and the CNI on the host read credentials and blocks the pod. Pod Identity does not need that path.
3. `eks-pod-identity-agent`. The VPC CNI, CoreDNS, and kube-proxy have published per-version tables. The agent does not, in the pages reviewed on 2026-11-07. Pin it after `scripts/check-addon-versions.sh`.

## Cleanup

Leave the cluster up.

## Cost

The control plane and two nodes are now billing. Add that to the NAT gateway from lab 01.
