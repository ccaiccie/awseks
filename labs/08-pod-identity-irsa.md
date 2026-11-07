# Lab 08 — Workload identity, not the node identity

## Objective

Call STS and S3 from two pods and show that the node role is not the role either pod received.

## Architecture

Pod Identity: the agent on the node, at `169.254.170.23`, and an association object in the EKS API. The trust principal is `pods.eks.amazonaws.com`.

IRSA: a projected service account token, the cluster OIDC provider, and `sts:AssumeRoleWithWebIdentity`. The trust principal is the OIDC provider. The annotation `eks.amazonaws.com/role-arn` is on the service account.

Stack 03 creates both. The namespace `lab-identity` is Terraform's. Do not create a second association with the CLI.

## Prerequisites

Stack 03 applied with `enable_identity_demo = true`. `terraform output identity_demo_bucket` prints the bucket name.

## Steps

```bash
BUCKET="$(terraform -chdir=terraform/stacks/03-platform output -raw identity_demo_bucket)"
kubectl apply -f manifests/lab08-identity/pods.yaml
kubectl -n lab-identity wait --for=condition=Ready pod/pod-identity pod/irsa
kubectl -n lab-identity exec pod-identity -- env | grep AWS_CONTAINER || true
kubectl -n lab-identity exec irsa -- env | grep AWS_ROLE_ARN || true
kubectl -n lab-identity exec pod-identity -- aws sts get-caller-identity
kubectl -n lab-identity exec irsa -- aws sts get-caller-identity
kubectl -n lab-identity exec pod-identity -- aws s3 cp "s3://${BUCKET}/lab08/hello.txt" -
kubectl -n lab-identity exec irsa -- aws s3 cp "s3://${BUCKET}/lab08/hello.txt" - || true
kubectl -n lab-identity exec irsa -- aws s3 ls "s3://${BUCKET}"
```

## Expected observations

Example only. `pod-identity` shows `AWS_CONTAINER_CREDENTIALS_FULL_URI` pointing at the link-local agent. `irsa` shows `AWS_ROLE_ARN` and a web identity token file. STS for the first pod returns the role `...-lab-workload`. STS for the second returns `...-lab-irsa`. Neither ARN is the node role from `terraform output -chdir=terraform/stacks/02-cluster`. `s3 cp` from the Pod Identity pod prints `practice object for the Pod Identity lab`. `s3 cp` from the IRSA pod returns `AccessDenied`. `s3 ls` from the IRSA pod lists the bucket.

## Questions

1. Why is the IRSA GetObject denied while ListBucket works?
2. What would `aws sts get-caller-identity` return if you removed the association and the pod fell back to IMDS?
3. Why is this image not the example application?

## Failure injection

Optional. Delete the Pod Identity association in the console or with the CLI, restart the pod, and run STS again. With hop limit 1 the pod should fail to get node credentials rather than silently become the node. Restore the association by re-applying stack 03. Do not leave the association deleted.

```bash
terraform -chdir=terraform/stacks/03-platform apply
```

Review the plan. It should want to recreate the association, not the cluster.

## Diagnostics

Both pods showing the node role means IMDS hop limit was raised and Pod Identity did not inject. `kubectl describe pod` should list the projected token or the agent environment. `AccessDenied` on ListBucket for the IRSA pod means the role policy or the bucket name does not match. An empty `AWS_ROLE_ARN` means the service account annotation is missing. That annotation is Terraform's. Do not add a second one in the pod spec.

## Answers

1. The IRSA role policy has only `s3:ListBucket` on the bucket ARN. GetObject is a different action on the object ARN. The Pod Identity role has both, and GetObject is limited to `lab08/*`.
2. With hop limit 1, the call fails. It does not return the node role. Hop limit 2 would return the node role, which is why the stack keeps the limit at 1.
3. `public.ecr.aws/aws-cli/aws-cli` runs as root. The example application remains the unprivileged nginx image. This pod drops capabilities and is only here so the shell can run `aws`.

## Cleanup

```bash
kubectl delete -f manifests/lab08-identity/pods.yaml
```

Leave the namespace. Stack 03 owns it. Deleting the namespace now makes the next Terraform plan recreate it.

## Cost

One S3 bucket and one small object. No hourly charge of consequence. The roles are free.
