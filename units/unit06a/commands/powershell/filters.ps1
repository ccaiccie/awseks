# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws ec2 describe-security-groups --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" --output json --no-cli-pager
aws ec2 describe-network-acls --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
aws ec2 describe-network-interfaces --profile "$AwsProfile" --region "$Region" --filters "Name=subnet-id,Values=$SubnetId" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,Groups:Groups}' --output json --no-cli-pager
