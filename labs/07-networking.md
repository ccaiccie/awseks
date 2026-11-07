# Lab 07 — CNI, Services, NAT, endpoints

## Objective

Separate a VPC route, a ClusterIP translation, and an IAM check on one cluster.

## Prerequisites

A Ready node from lab 03 or 04. Read [docs/network-model.md](../docs/network-model.md). The class scenes are F04–F08 and F12–F13 under [class/diagrams/](../class/diagrams/README.md). Chapter 10–13 in [docs/chapter-map.md](../docs/chapter-map.md).

## Commands

```bash
kubectl get pods -n kube-system -o wide -l k8s-app=aws-node
kubectl get svc -n kube-system kube-dns -o wide
kubectl get endpointslices -n kube-system -l k8s-app=kube-dns
aws ec2 describe-route-tables --filters "Name=tag:Cluster,Values=${CLUSTER_NAME}" \
  --query 'RouteTables[].Routes'
```

Use the cluster name for the path you built. A `0.0.0.0/0` target that is a NAT gateway is VPC egress. `172.20.0.0/16` must not appear as a VPC route. CoreDNS answers names; kube-proxy DNATs the ClusterIP; conntrack rewrites the return.

The class script `class/labs/scripts/05-observe-network.sh` does this observation on an `eksclass-cli-*` stack only.

## Expected observation

`aws-node`, `kube-proxy`, and `coredns` are running. Pod IPs are inside the VPC CIDR, not in `172.20.0.0/16`. Two pods on one node share that node's ENI path. A pod on the other node is a VPC local route between ENIs.

## Question

Why can an ECR interface endpoint still fail an image pull?

## Explanation

Image manifests come from ECR API and ECR DKR. Layers are objects in S3. The S3 gateway endpoint is the layer path. Private registry endpoints do not pull from Docker Hub or `registry.k8s.io`.

## Safe failure

`kubectl exec` to a missing DNS name inside the cluster. The failure is DNS, not the security group. Do not edit a route table to "add" the service CIDR.

## Cost

Reading is free. `class/labs/scripts/10-endpoints.sh` creates interface endpoints and is a separate bill. The repo leaves them off unless `nat_strategy=none` or `enable_interface_endpoints=true`.

## Cleanup

None for read-only checks. Delete endpoints only if that optional script created them, using the class cleanup or the repo cleanup for the stack that owns them.
