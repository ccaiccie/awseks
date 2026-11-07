#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating
: "$(get az-a)"; [[ -n "$(get az-a)" && -n "$(get az-b)" ]] || { echo 'Run preflight.' >&2; exit 1; }
tag() { aws ec2 create-tags --resources "$1" --tags Key=EksClassStack,Value="$STACK" Key=Name,Value="$STACK-$2"; }
VPC=$(ensure vpc aws ec2 create-vpc --cidr-block 10.42.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=EksClassStack,Value=$STACK},{Key=Name,Value=$STACK}]" --query Vpc.VpcId --output text)
aws ec2 wait vpc-available --vpc-ids "$VPC"; owned_vpc
aws ec2 modify-vpc-attribute --vpc-id "$VPC" --enable-dns-support '{"Value":true}'
aws ec2 modify-vpc-attribute --vpc-id "$VPC" --enable-dns-hostnames '{"Value":true}'
IGW=$(ensure igw aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=EksClassStack,Value=$STACK}]" --query InternetGateway.InternetGatewayId --output text)
if [[ "$(aws ec2 describe-internet-gateways --internet-gateway-ids "$IGW" --query 'length(InternetGateways[0].Attachments)' --output text)" == 0 ]]; then aws ec2 attach-internet-gateway --vpc-id "$VPC" --internet-gateway-id "$IGW"; fi
for spec in 'public-a 10.42.0.0/24 a' 'public-b 10.42.1.0/24 b' 'private-a 10.42.16.0/20 a' 'private-b 10.42.32.0/20 b'; do
 read -r key cidr az <<< "$spec"
 SUB=$(ensure "$key" aws ec2 create-subnet --vpc-id "$VPC" --cidr-block "$cidr" --availability-zone "$(get "az-$az")" --tag-specifications "ResourceType=subnet,Tags=[{Key=EksClassStack,Value=$STACK},{Key=Name,Value=$STACK-$key}]" --query Subnet.SubnetId --output text)
 # Public LB/NAT subnets do not automatically assign public IPs to instances either.
 aws ec2 modify-subnet-attribute --subnet-id "$SUB" --no-map-public-ip-on-launch
 if [[ "$key" == public-* ]]; then role_tag=kubernetes.io/role/elb; else role_tag=kubernetes.io/role/internal-elb; fi
 aws ec2 create-tags --resources "$SUB" --tags "Key=$role_tag,Value=1" "Key=kubernetes.io/cluster/$STACK,Value=shared"
done
PUB_RT=$(ensure public-rt aws ec2 create-route-table --vpc-id "$VPC" --tag-specifications "ResourceType=route-table,Tags=[{Key=EksClassStack,Value=$STACK}]" --query RouteTable.RouteTableId --output text)
route() {
 local rt="$1" target_flag="$2" target="$3"
 if [[ "$(aws ec2 describe-route-tables --route-table-ids "$rt" --query 'length(RouteTables[0].Routes[?DestinationCidrBlock==`0.0.0.0/0`])' --output text)" == 0 ]]; then
  aws ec2 create-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 "$target_flag" "$target"
 fi
}
route "$PUB_RT" --gateway-id "$IGW"
for az in a b; do
 ensure "assoc-public-$az" aws ec2 associate-route-table --route-table-id "$PUB_RT" --subnet-id "$(get "public-$az")" --query AssociationId --output text >/dev/null
 EIP=$(ensure "eip-$az" aws ec2 allocate-address --domain vpc --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=EksClassStack,Value=$STACK}]" --query AllocationId --output text)
 NAT=$(ensure "nat-$az" aws ec2 create-nat-gateway --subnet-id "$(get "public-$az")" --allocation-id "$EIP" --client-token "$STACK-nat-$az" --tag-specifications "ResourceType=natgateway,Tags=[{Key=EksClassStack,Value=$STACK}]" --query NatGateway.NatGatewayId --output text)
 aws ec2 wait nat-gateway-available --nat-gateway-ids "$NAT"
 RT=$(ensure "private-rt-$az" aws ec2 create-route-table --vpc-id "$VPC" --tag-specifications "ResourceType=route-table,Tags=[{Key=EksClassStack,Value=$STACK}]" --query RouteTable.RouteTableId --output text)
 route "$RT" --nat-gateway-id "$NAT"
 ensure "assoc-private-$az" aws ec2 associate-route-table --route-table-id "$RT" --subnet-id "$(get "private-$az")" --query AssociationId --output text >/dev/null
done
aws ec2 describe-route-tables --filters Name=vpc-id,Values="$VPC" --output json
# Default SG/NACL remain AWS defaults. Cluster creates its own SG; no SSH ingress is added.
aws ec2 describe-network-acls --filters Name=vpc-id,Values="$VPC"
echo 'Checkpoint: two private defaults to same-AZ NATs; public default IGW; no service-CIDR route.'
