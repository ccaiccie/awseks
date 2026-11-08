# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --filter "Name=vpc-id,Values=$VpcId" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId,Type:ConnectivityType,Addresses:NatGatewayAddresses}' --output json --no-cli-pager
aws ec2 describe-internet-gateways --profile "$AwsProfile" --region "$Region" --filters "Name=attachment.vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --query 'Subnets[].{ID:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock}' --output table --no-cli-pager
