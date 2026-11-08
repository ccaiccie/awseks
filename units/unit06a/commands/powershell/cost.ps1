# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws eks list-clusters --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-nat-gateways --profile "$AwsProfile" --region "$Region" --query 'NatGateways[].{ID:NatGatewayId,State:State,Subnet:SubnetId}' --output table --no-cli-pager
aws ec2 describe-addresses --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws ec2 describe-volumes --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
