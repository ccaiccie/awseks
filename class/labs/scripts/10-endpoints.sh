#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; owned_vpc
VPC=$(get vpc)
SG=$(ensure endpoint-sg aws ec2 create-security-group --group-name "$STACK-endpoints" --description 'HTTPS to teaching VPC endpoints from VPC workloads' --vpc-id "$VPC" --tag-specifications "ResourceType=security-group,Tags=[{Key=EksClassStack,Value=$STACK}]" --query GroupId --output text)
# This private VPC CIDR allow is deliberate for the endpoint lab; tighten to caller SGs in production.
if [[ -z "$(get endpoint-sg-rule)" ]]; then
 aws ec2 authorize-security-group-ingress --group-id "$SG" --ip-permissions '[{"IpProtocol":"tcp","FromPort":443,"ToPort":443,"IpRanges":[{"CidrIp":"10.42.0.0/16","Description":"Teaching VPC clients"}]}]'
 put endpoint-sg-rule yes
fi
# These six two-AZ interface endpoints are billable ADDITIONAL infrastructure; NAT stays in place.
# Do not remove NAT: public registries/controller dependencies may still need it.
for service in ecr.api ecr.dkr sts eks-auth logs ec2; do
 ensure "vpce-$service" aws ec2 create-vpc-endpoint --vpc-id "$VPC" --vpc-endpoint-type Interface --service-name "com.amazonaws.$AWS_REGION.$service" --subnet-ids "$(get private-a)" "$(get private-b)" --security-group-ids "$SG" --private-dns-enabled --tag-specifications "ResourceType=vpc-endpoint,Tags=[{Key=EksClassStack,Value=$STACK}]" --query VpcEndpoint.VpcEndpointId --output text >/dev/null
done
ensure vpce-s3 aws ec2 create-vpc-endpoint --vpc-id "$VPC" --vpc-endpoint-type Gateway --service-name "com.amazonaws.$AWS_REGION.s3" --route-table-ids "$(get private-rt-a)" "$(get private-rt-b)" --tag-specifications "ResourceType=vpc-endpoint,Tags=[{Key=EksClassStack,Value=$STACK}]" --query VpcEndpoint.VpcEndpointId --output text >/dev/null
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values="$VPC" --query 'VpcEndpoints[].{ID:VpcEndpointId,State:State,Service:ServiceName,DNS:DnsEntries}'
echo 'Checkpoint: wait for available before testing. Default endpoint policies allow more than production least privilege; tighten in a separate reviewed lab.'
echo 'ECR API+Dkr+S3 supports private ECR layer pulls, not arbitrary public registries. LBC may also need ELB service endpoints; inspect supported regional endpoint services before isolated design.'
