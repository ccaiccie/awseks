# Architecture

Standard EKS. Managed EC2. IPv4. Authentication mode `API`. Support type `STANDARD`. Auto Mode compute, Auto Mode block storage, and the Auto Mode elastic load balancing flag are left unset, so they stay off.

## Layout

- VPC `10.0.0.0/16` with DNS hostnames enabled.
- Two public `/24` subnets by default (`10.0.0.0/24`, `10.0.1.0/24`) and two private `/24` subnets (`10.0.10.0/24`, `10.0.11.0/24`). `az_count` may be 3.
- Public route table sends `0.0.0.0/0` to the internet gateway. Nodes are not launched there.
- Private route tables send `0.0.0.0/0` to a NAT gateway when `nat_strategy` is `single` or `per_az`. `single` uses the NAT in the first public subnet for every private subnet. `per_az` gives each private subnet its own NAT.
- `nat_strategy = none` has no default route. Interface endpoints are required or image pulls and EKS Auth fail.
- An S3 gateway endpoint is always associated with the private route tables. Image layers are objects in S3.
- Kubernetes service CIDR `172.20.0.0/16`. It is not a subnet and it does not appear in the VPC route table.

## Cluster

Control plane ENIs are placed in the private subnets. The private API endpoint is enabled. The public endpoint is disabled unless `enable_public_endpoint` is true and `public_access_cidrs` is a non-empty list that is not `0.0.0.0/0`.

EKS creates `eks-cluster-sg-<name>-<id>` and attaches it to the control plane ENIs and to managed nodes. Its default rules allow all traffic from itself and all outbound traffic. An additional security group allows TCP 443 from the VPC CIDR so a client inside the VPC can reach the private API. That additional group is not attached to nodes. Nodes already share the cluster security group.

`bootstrap_self_managed_addons` is false. The managed add-ons are the only vpc-cni, kube-proxy, and CoreDNS. Creating those add-ons and the node group in one dependency chain deadlocks, so the node group does not wait on the CNI add-on and the CNI add-on does not wait on the node group. CoreDNS and the EBS CSI driver wait until the node group is active.

## Nodes

Managed node group, AMI type `AL2023_x86_64_STANDARD`, capacity `ON_DEMAND`, two `t3.medium` instances, encrypted gp3 root of 20 GiB. The launch template sets IMDSv2 (`HttpTokens=required`) and hop limit 1. There is no `remote_access` block and no key name. Hop limit 1 lets the kubelet and host-network agents read IMDS and stops ordinary pods from doing so.

The node role has `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryPullOnly`, and `AmazonEKS_CNI_Policy`. The CNI policy is on the node role for the first apply because `aws-node` is host-networked and must create ENIs before a Pod Identity agent can be the only identity path. A later apply can move it. See [iam.md](iam.md).

## Add-ons and the controller

| Add-on | Identity |
| --- | --- |
| eks-pod-identity-agent | node role, including `eks-auth:AssumeRoleForPodIdentity` from `AmazonEKSWorkerNodePolicy` |
| vpc-cni | node role, unless `vpc_cni_use_pod_identity` is later set |
| kube-proxy | no AWS IAM |
| coredns | no AWS IAM |
| aws-ebs-csi-driver | Pod Identity role with `AmazonEBSCSIDriverPolicyV2`, service account `ebs-csi-controller-sa` |
| AWS Load Balancer Controller | Pod Identity role, Helm chart 3.6.2, not in the Terraform apply |

VPC CNI is configured with `enableNetworkPolicy=true` so the NetworkPolicy lab has an enforcement point.

## Tags

`Project=awseks-practice`, `Provisioner=terraform` or `Provisioner=awscli`, plus `Owner` and `Cluster`. Subnets also carry `kubernetes.io/role/elb` or `kubernetes.io/role/internal-elb` so the load balancer controller can see them.
