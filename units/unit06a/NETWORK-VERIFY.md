# Complete dependency verification, not one green field

After identity, use existing VpcId/SubnetId read from your authorized account. No existing network? Skip these AWS checks and use the labelled offline plan.

Both Bash and PowerShell use the same AWS commands after their different variable assignments from settings/addresses/routing lectures:
```bash
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id "$VpcId" --attribute enableDnsSupport --output json --no-cli-pager
aws ec2 describe-vpc-attribute --profile "$AwsProfile" --region "$Region" --vpc-id "$VpcId" --attribute enableDnsHostnames --output json --no-cli-pager
```
Both flags must report Value=true for the intended EKS VPC. These are reads, not modify-vpc-attribute. Inspect secondary VPC CIDRs as well as primary. Check Service/VPN/on-prem/peered ranges against central IPAM: local two-range checks are not global proof.

Read AWS CLI describe-subnets Free field (AvailableIpAddressCount) or verified Terraform aws_subnet.available_ip_address_count. EKS cluster subnets need at least six available IPs each (16 recommended), at least two AZs; do not infer that sufficient IPs for control-plane ENIs means sufficient nodes/Pods/LBs. AWS network requirements also exclude specific AZ IDs in some Regions; check the current official network-reqs page before choosing your two AZs, not just any two EC2 available zones.

Route evidence ledger per direction: source/subnet -> explicit association or main fallback -> destination -> matching prefixes -> most-specific active winner -> real target. Check route state blackhole. For private egress: private default -> same-AZ NAT in course design -> NAT subnet table default -> attached IGW; reverse translations and return access-list rules are separate checks. NAT state=available alone is insufficient. This design describes zonal NAT gateways, not all possible NAT products.

Filters: identify ENI SG attachments and subnet NACL association; read direction, protocol, peer CIDR and destination port; first matching numbered NACL rule wins. Return port is ephemeral at the original client; NAT may translate ports, so use the actual flow in the correct subnet view. Stateful SG tracking does not override a stateless NACL deny. Do not open all inbound ports or delete service ENIs.

Full commands are in FOLLOW-ALONG.md addresses, routing, nat and filters sections and the matching command reference files. This checklist does not replace those commands. No live packet trace or AWS connectivity result is claimed.
