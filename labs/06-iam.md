# Lab 06 — Humans, nodes, Pod Identity, IRSA

## Objective

Name the principal for an API call, a node, and a controller pod.

## Prerequisites

Labs 03 or 04. Diagrams [03-iam-access-rbac.svg](../docs/diagrams/03-iam-access-rbac.svg) and [04-workload-identity.svg](../docs/diagrams/04-workload-identity.svg). [docs/iam.md](../docs/iam.md).

## Commands

```bash
aws eks list-access-entries --cluster-name "$CLUSTER_NAME"
aws eks list-pod-identity-associations --cluster-name "$CLUSTER_NAME" \
  --namespace kube-system --service-account ebs-csi-controller-sa
kubectl auth can-i get pods -A
aws sts get-caller-identity --query Arn --output text
```

Optional IRSA, only if you want the contrast. This creates an IAM OIDC provider. It is not required for Pod Identity.

```bash
ISSUER="$(aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.identity.oidc.issuer' --output text)"
echo "$ISSUER"
```

Stop there unless you have read the IRSA trust example in [docs/iam.md](../docs/iam.md) and you are ready to delete the provider later. Do not attach `AdministratorAccess` to the thumbprint experiment.

## Expected observation

`list-access-entries` includes your creator principal and the node role. It does not include the EBS CSI role. That role appears in the Pod Identity association, with service account `ebs-csi-controller-sa`. `kubectl auth can-i` is Kubernetes. `get-caller-identity` is AWS. They can disagree.

## Question

Why is `AmazonEKS_CNI_Policy` on the node role acceptable with hop limit 1, and a workload policy on that same role not acceptable?

## Explanation

`aws-node` uses the host network, so it can reach IMDS at hop limit 1. A normal pod cannot. A policy on the node role is still available to every host-network process and to anything that escapes the hop limit. Prefer a Pod Identity role for controllers. The CNI move is a second apply, documented in [docs/iam.md](../docs/iam.md), not the first.

## Safe failure

`kubectl auth can-i get secrets -A` as a viewer principal, if you set `viewer_principal_arn`. The answer is no for secrets if you only attached `AmazonEKSViewPolicy`... check the access policy page before you assert that. View is broad on reads. The safe failure that is certain: call `aws eks describe-cluster` with a profile that has no `eks:DescribeCluster`. You get `AccessDeniedException` and the cluster stays up.

## Troubleshooting

`sts:AssumeRole` denied inside an EBS pod means the trust condition service account does not match `ebs-csi-controller-sa`, or the agent cannot reach `eks-auth`.

## Cost

None for the reads. An OIDC provider is free of hourly compute but is another IAM object to delete.

## Cleanup

Delete an OIDC provider you created, by its ARN, when you are done. Do not delete the cluster role.
