# Cost and the defaults that keep it down

Prices below are the public rates retrieved on 2026-11-07. Your Region's price list wins. A partial hour of a NAT gateway is billed as a full hour.

| Piece | Default | Published rate to quote |
| --- | --- | --- |
| EKS control plane, standard support | one cluster, version 1.35 | $0.10 per hour ([EKS pricing](https://aws.amazon.com/eks/pricing/)) |
| EKS extended support | not selected | $0.60 per hour |
| NAT gateway | one, shared by every private subnet | VPC pricing example: $0.045 per hour and $0.045 per GB ([VPC pricing](https://aws.amazon.com/vpc/pricing/)) |
| NAT per AZ | off | Multiply the hourly rate by the number of AZs, plus cross-AZ data if pods hairpin |
| Worker nodes | 2 x t3.medium on demand | Look up the current on-demand Linux price. t3.micro is rejected. t3.small is the smallest allowed size and is tight once the CNI, kube-proxy, and the Pod Identity agent are running |
| Root disks | 20 GiB gp3, encrypted, delete on termination | EBS gp3 storage and IOPS. Small at this size |
| S3 gateway endpoint | on | No hourly charge |
| Interface endpoints | off until `enable-interface-endpoints` | Hourly charge per endpoint per AZ, plus data processing |
| Flow logs | off | CloudWatch ingestion |
| Control plane logs | off | CloudWatch ingestion |
| Load balancer | none until a lab Ingress or Service | ALB or NLB hourly charge plus capacity units |
| EFS | off until `enable-efs` | Storage plus a mount target in each AZ |
| Karpenter | off until `enable-karpenter` | Another node role and, if the NodePool scales, more instances. The pool limit in the sample is 2 vCPU |
| KMS | one customer key | About $1 per month until the 7 day deletion window finishes |
| Public IPv4 | the NAT gateway's address, and each internet-facing load balancer | See the public IPv4 section of the VPC pricing page |

## Sizing

Two nodes are required so the cross-node labs have somewhere to land. `desired` defaults to 2, `max` to 3. The third node exists so a rolling replace during an upgrade has a place to go. It does not run until the node group scales.

`t3.medium` is 2 vCPU and 4 GiB. That is the class default because the system DaemonSets and two small nginx pods fit, and HPA can add one more replica. `t3.small` (2 GiB) is the minimum the guardrail allows. Use it only if you have already watched `kubectl describe node` for memory pressure.

Spot is a second node group at desired 0. It costs nothing until lab 17 scales it. Those nodes are tainted `awseks.practice/capacity=spot:NoSchedule`.

## What is expensive on purpose

These variables do nothing until the matching confirmation string is set:

| Variable | Confirmation |
| --- | --- |
| `enable_interface_endpoints` | `enable-interface-endpoints` |
| `enable_efs` | `enable-efs` |
| `enable_karpenter` | `enable-karpenter` |

`nat_gateway_per_az = true` does not use a second string. The plan shows one NAT gateway resource per AZ. Read that plan.

`allow_expensive_nodes = true` leaves the t3 allow-list. Do not set it for this class.
