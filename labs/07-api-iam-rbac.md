# Lab 07 — Public and private API, IAM, and RBAC

## Objective

Separate three failures: the packet cannot reach the endpoint, IAM has no access entry, and Kubernetes RBAC denies the verb.

## Architecture

The IAM/RBAC figure in [docs/DIAGRAMS.md](../docs/DIAGRAMS.md). The private endpoint is an ENI in your subnet. The public endpoint is an AWS-managed address filtered by the CIDR list. `authentication_mode` is `API`, so there is no `aws-auth` ConfigMap.

## Prerequisites

Lab 02. Your principal is an access entry with `AmazonEKSClusterAdminPolicy`.

## Steps

```bash
aws eks describe-cluster --name "$CLUSTER_NAME" \
  --query 'cluster.resourcesVpcConfig.{public:endpointPublicAccess,private:endpointPrivateAccess,cidrs:publicAccessCidrs,vpc:vpcId}'
kubectl auth can-i list pods --all-namespaces
kubectl auth can-i create deployments -n lab-fundamentals
```

Create a namespace-scoped identity that is only a reader. This is kubectl, not Terraform.

```bash
kubectl create namespace lab-rbac --dry-run=client -o yaml | kubectl apply -f -
kubectl -n lab-rbac create serviceaccount reader
kubectl -n lab-rbac create role reader --verb=get,list --resource=pods
kubectl -n lab-rbac create rolebinding reader --role=reader --serviceaccount=lab-rbac:reader
kubectl auth can-i list pods -n lab-rbac --as=system:serviceaccount:lab-rbac:reader
kubectl auth can-i delete pods -n lab-rbac --as=system:serviceaccount:lab-rbac:reader
```

## Expected observations

Example only. Your user can list pods across namespaces: `yes`. The reader service account can list pods in `lab-rbac` and cannot delete them: `no`.

## Questions

1. The reader service account has no IAM role. Can it call `aws s3 ls`? Why?
2. You add a colleague's IAM role as an access entry with `AmazonEKSViewPolicy` and no RoleBinding. What can they do?
3. Private access is on and public access is off. Your laptop times out. Which of the three gates failed?

## Failure injection

Optional. Change `endpoint_public_access_cidrs` to a documentation address you do not own, such as `203.0.113.10/32`, plan, and apply only if everyone in the room can still use the private endpoint. Otherwise stop at the plan and read the CIDR diff. Restore your real `/32` before anyone goes home.

Do not set `0.0.0.0/0`. The guardrail will reject the plan. That rejection is the demonstration.

## Diagnostics

Timeout with no HTTP response: network path or CIDR. `AccessDenied` from STS or an EKS error before HTTP 401: IAM. HTTP 401 or 403 from the API server: authentication succeeded far enough for RBAC, or the token is wrong. `kubectl auth can-i` tells you the RBAC answer for the current user without mutating anything.

## Answers

1. No. A service account token is a Kubernetes credential. AWS will not accept it unless Pod Identity or IRSA is configured, which lab 08 adds for different accounts.
2. `AmazonEKSViewPolicy` is an EKS access policy. It grants read-style Kubernetes access through the access entry, without a RoleBinding you wrote. It does not grant S3. Check the current policy list in the EKS access policy docs before you describe it as read-only for every resource, because AWS adds policies over time.
3. The packet never reached the private ENI. IAM and RBAC were not asked.

## Cleanup

```bash
kubectl delete namespace lab-rbac
```

## Cost

None beyond the cluster you already have. A mistaken public `/32` locks the room out of the public endpoint until you apply the right one. Private access still works from inside the VPC.
