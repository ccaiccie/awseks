# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws ec2 describe-vpcs --profile "$AwsProfile" --region "$Region" --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,OtherCIDRs:CidrBlockAssociationSet}' --output json --no-cli-pager
VpcId="REPLACE_WITH_EXISTING_VPC_ID"
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'NetworkInterfaces[].{ID:NetworkInterfaceId,Subnet:SubnetId,Type:InterfaceType,IPs:PrivateIpAddresses,Description:Description}' --output json --no-cli-pager
