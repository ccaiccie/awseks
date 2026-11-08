# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
# Only after selecting an authorized EXISTING SubnetId from the subnet list:
aws ec2 describe-subnets --profile "$AwsProfile" --region "$Region" --subnet-ids "$SubnetId" --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone,Free:AvailableIpAddressCount}' --output table --no-cli-pager
