# Supported APIs, not invented equivalents

Pinned AWS provider 6.21.0 was initialized and its actual provider schema inspected locally, without AWS credentials. Terraform validate is a schema/syntax test, NOT an authenticated plan. Terraform 1.13.5 is the tested local binary, not a claim of latest release.

| Concept | Supported Terraform in this package | Deliberate limit |
|---|---|---|
| Identity/account guard/Region | aws_caller_identity, aws_region.region, provider allowed_account_ids | Does not prove other API permissions |
| AZ names/IDs/state | aws_availability_zones | Zone availability is not instance capacity |
| Type offered locations/ENI limits | aws_ec2_instance_type_offerings, aws_ec2_instance_type | Offered is not spare capacity; maxPods formula only secondary-IP example |
| EKS lifecycle | aws_eks_cluster_versions(version_status="STANDARD_SUPPORT").cluster_versions | Genuine provider 6.21.0 data source, not invented; review dates/choice manually |
| One compatible VPC CNI version | optional aws_eks_addon_version with reviewed kubernetes_version | most_recent=true yields latest compatible, NOT a recommendation for every configuration/architecture; CLI gives full compatibility detail |
| Existing subnet CIDR/AZ/VPC/free IPs | aws_subnet.available_ip_address_count | Point-in-time free count, not guaranteed future reserve |
| Local CIDR/capacity | cidrsubnet, pow, sum, arithmetic locals | No fake cidroverlaps or packet-tracer function. Python checks Service RFC1918/range/overlap |
| Effective IAM decisions | CLI reads + optional IAM simulator | Terraform does not implement AWS policy evaluation; simulator has context/SCP/session limits |
| Shell credential precedence/versions | local CLI tools | Not Terraform data or IAM permissions |
| Budget/end time/current prices | CLI/official pricing pages/local guard | No cost cap, no automatic cleanup, no fabricated pricing function |
| Existing VPC/DNS/main table | optional aws_vpc.existing | Supported DNS flags/CIDR associations/main table, not network creation |
| Existing route tables/NAT/IGW | optional aws_route_table.existing, aws_nat_gateway.existing, aws_internet_gateway.existing | Real routes/associations/gateway attachments; CLI supplies route State and explicit packet/LPM reasoning |
| Existing ALB chain | optional aws_lb, aws_lb_listener, aws_lb_listener_rule, aws_lb_target_group | Supported configuration/placement reads. health_check is policy; live per-target health remains CLI describe-target-health. Listener/state metadata private |
| Kubernetes API / Services | aws_eks_cluster endpoint and Service-pool observations; kubectl for actual Services/EndpointSlices | AWS provider does not pretend to query Kubernetes objects; dedicated private kubeconfig optional local write, not access grant |
| Existing cluster | optional aws_eks_cluster.existing | Version/status/VPC/Service network/support/log reads, no cluster creation/auth token |
| SG/NACL/ENI/filter reasoning | full AWS CLI reads shown beside lectures | Supported SG metadata is not an effective-policy or stateful packet evaluator; no invented one-to-one full-rule/packet-trace attributes |

No resource/module/import blocks, no AWS infrastructure ownership. Offline and read-only are separate configurations/states. Data-only apply writes LOCAL observations/state; do not publish state/plans. There is no cluster/network Terraform creation in Unit 6A, avoiding a duplicate Unit 6B owner. A later billable Terraform build must be an alternative namespace/state with its own explicit reviewed lifecycle.
