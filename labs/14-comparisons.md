# Lab 14 — IPv6, Auto Mode, and Fargate

## Objective

Keep three compute and address modes distinct. This lab does not build them.

## Prerequisites

Chapter 06 and 15 of [docs/chapter-map.md](../docs/chapter-map.md). Snapshots `class/sources/S18.txt`, `S19.txt`, `S44.txt`, `S46.txt`, and `S11.txt`.

## Diagram

There is no single diagram that is all three. Use F18 and F19 as variant cards. Do not redraw the standard-EKS architecture SVG as Auto Mode.

## What the pages actually say

**Standard track in this repo.** Managed EC2, AL2023, VPC CNI `aws-node`, kube-proxy on the node, CoreDNS Deployment, EBS provisioner `ebs.csi.aws.com`, load balancer controller chart 3.6.2 if you install it. IPv4 service CIDR chosen at creation.

**Fargate.** A pod runs in its own VM. No DaemonSets, privileged pods, or hostNetwork on Fargate. No EBS mount. EFS is static provisioning only. Pod Identity's agent is not the Fargate identity path; IRSA is the documented alternative. Load balancer targets are IP.

**Auto Mode.** You do not install `aws-node`, the pod identity agent, or the EBS CSI driver for Auto Mode nodes. Networking knobs such as warm IP and ENIConfig are not the same settings. Mixed clusters still need a CoreDNS Deployment for non-Auto nodes. Gateway API works only after the Auto Mode load-balancing gateway configuration is enabled, with controller `eks.amazonaws.com/gateway-alb` or `gateway-nlb`. The Auto Mode page lists HTTPRoute, GRPCRoute, TCPRoute, and UDPRoute. It does not list TLSRoute. Security groups for pods on Auto Mode, Kubernetes 1.36 or later, are `SecurityGroupPolicy` in `eks.amazonaws.com/v1`, which is not the standard `vpcresources.k8s.aws` object. Block storage uses `ebs.csi.eks.amazonaws.com`.

**IPv6.** The family is chosen when the cluster is created and is not a flip of this IPv4 service CIDR. EKS does not describe dual-stack pod and service addresses. An optional IPv6 cluster is a second cluster, not a change to `awseks-tf-lab` or `awseks-cli-lab`.

## Commands

None that create these modes. Reading is the lab:

```bash
sed -n '1,80p' class/sources/S11.txt
sed -n '1,30p' class/sources/S46.txt
```

## Question

Which of those three can use the standard `aws-node` environment variables?

## Explanation

The standard EC2 track. Fargate and Auto Mode do not take those knobs. Copying them into an Auto Mode NodeClass is the mistake chapter 06 is written to prevent.

## Safe failure

There is no apply. If a manifest names `eks.amazonaws.com/alb` or `ebs.csi.eks.amazonaws.com` on the standard cluster, do not apply it here.

## Cost

Zero if you only read.

## Cleanup

None.
