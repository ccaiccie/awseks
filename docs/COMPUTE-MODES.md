# Standard EKS, Auto Mode, Fargate, self-managed

This repository builds **standard EKS** with a **managed node group** on **EC2** and **IPv4**. `compute_config` is null. `create_auto_mode_iam_resources` and `create_node_iam_role` are false, so the EKS module's Auto Mode role is not created.

## Standard + managed node group

You own the VPC, the subnets, the NAT decision, and the node IAM role. AWS owns the control plane and replaces node instances when you change the group. The VPC CNI, kube-proxy, CoreDNS, the Pod Identity agent, and the EBS CSI driver are Amazon EKS add-ons with pinned versions where AWS publishes a table.

Managed node groups do not SSH. IMDSv2 is required and the hop limit is 1, so pods do not see instance metadata. Pod Identity does not need IMDS.

## Auto Mode

Auto Mode runs the compute, the load balancer controller, and block storage inside the EKS service. You do not install the VPC CNI, kube-proxy, or the Pod Identity agent yourself. The Pod Identity agent is built in. The networking labs in this class are about those components, so Auto Mode would hide the thing being taught. AWS describes this in the add-on pages: with Auto Mode you don't install those add-ons.

Turning `compute_config.enabled` on in this module is a different cluster shape. Do not flip it on an existing class cluster.

## Fargate

Fargate is a profile that runs selected pods on AWS-managed VMs. The VPC CNI still provides pod IPs, but you do not patch kube-proxy on those pods: kube-proxy is not installed on Fargate nodes. DaemonSets such as the VPC CNI agent and the load balancer readiness gates do not run there in the same way. A Fargate profile is not in these stacks.

## Self-managed nodes

You own the autoscaling group, the AMI, and the bootstrap. The EKS module can build that too. This class uses the managed node group so a bad user-data edit cannot block the room. Lab 17 still drains nodes and uses a PodDisruptionBudget. That procedure is the same idea you need when the group is self-managed.

## IPv6

`ip_family` is `ipv4`. The service CIDR is `172.20.0.0/16` unless you change it. IPv6 clusters assign pod and service addresses from a different range and need the IPv6 CNI policy. That is a separate class.
