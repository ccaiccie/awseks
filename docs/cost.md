# Cost

Read this before `terraform apply` and before `cli/bin/provision.sh`.

This file does not quote a dollar amount. NAT gateway, EKS control plane, EC2, interface VPC endpoint, public IPv4, CloudWatch ingestion, and load balancer prices change and differ by region. Open the AWS pricing pages for those products and the AWS Pricing Calculator with your region before you create anything.

What this lab turns on by default:

- One EKS control plane on standard support (`STANDARD`, not extended).
- Two `t3.medium` on-demand nodes with 20 GiB gp3 each.
- One NAT gateway and its public IPv4 address when `nat_strategy` is `single`.
- One S3 gateway endpoint, which does not have an hourly charge.
- The private API endpoint, which does not add a public load balancer.

What stays off until you opt in:

- A second or third NAT gateway (`per_az`).
- Interface endpoints (`enable_interface_endpoints` or `nat_strategy=none`). Each interface endpoint is created in every private subnet.
- The public API. Enabling it does not by itself create a NAT, but your client must be in the allow list.
- Control plane logs and VPC flow logs.
- A KMS key for secret encryption.
- The AWS Load Balancer Controller's ALB or NLB. The controller Helm release does not create a load balancer until an Ingress or a `Service` of type `LoadBalancer` exists.
- Spot capacity. Spot is cheaper until an interruption, and it is a bad first cluster.
- EBS volumes from the storage lab. `reclaimPolicy: Delete` removes the disk with the PVC. `Retain` would keep billing after the PVC is gone.

Leaving the stack up overnight still bills the control plane, the nodes, and the NAT gateway. Cleanup in [cleanup.md](cleanup.md) is the off switch. After cleanup, look for leftover NAT gateways, unassociated Elastic IPs, load balancers tagged `elbv2.k8s.aws/cluster`, and EBS volumes. This repository cannot see your bill.
