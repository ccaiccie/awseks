# Lab 05 — Private API, public allow list, kubeconfig

## Objective

See which network path your kubectl is using.

## Prerequisites

A cluster from lab 03 or 04. Diagram [docs/diagrams/02-api-access.svg](../docs/diagrams/02-api-access.svg).

## Commands

```bash
aws eks describe-cluster --name "$CLUSTER_NAME" \
  --query 'cluster.resourcesVpcConfig.{private:endpointPrivateAccess,public:endpointPublicAccess,cidrs:publicAccessCidrs,endpoint:endpoint}'
kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
kubectl get --raw='/readyz'
```

Replace `$CLUSTER_NAME` with the context you exported. Do not run this against a cluster whose context you have not checked.

## Expected observation

`private` is true. `server` in the kubeconfig equals `endpoint`. `readyz` returns `ok`. If `public` is false, this only works from a network that can route to the private ENIs (the VPC, or a tunnel you already operate). If `public` is true, your address is inside `cidrs`, and `cidrs` is not `0.0.0.0/0`.

## Question

Why can `publicAccessCidrs` contain `0.0.0.0/0` while the endpoint is still closed?

## Explanation

When the public endpoint is disabled, AWS still stores a default CIDR list on the object. The boolean `endpointPublicAccess` is what opens it. This lab only sends a CIDR list when that boolean is true, and it refuses `0.0.0.0/0` in that case. [docs/troubleshooting.md](../docs/troubleshooting.md) shows the shape.

## Safe failure

From a network that is not your allow list, `kubectl get --raw=/readyz` times out or is refused. Your shell is fine. Fix the path, do not add `0.0.0.0/0`.

## Troubleshooting

`Unauthorized` means the TCP connection worked and the access entry did not. That is lab 06. A timeout is this lab.

## Cost

No new resources. Turning the public endpoint on later is an `update-cluster-config` and does not add a NAT.

## Cleanup

None if you only read. If you enabled the public endpoint for the lab and want it off, set the flag false and apply (Terraform) or `aws eks update-cluster-config` with `endpointPublicAccess=false` (CLI). Keep the private endpoint true.
