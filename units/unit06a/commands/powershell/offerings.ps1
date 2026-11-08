# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
$InstanceType = "m6i.large"
aws ec2 describe-instance-type-offerings --profile "$AwsProfile" --region "$Region" --location-type availability-zone --filters "Name=instance-type,Values=$InstanceType" --output table --no-cli-pager
aws ec2 describe-instance-types --profile "$AwsProfile" --region "$Region" --instance-types "$InstanceType" --query 'InstanceTypes[].{Type:InstanceType,ENIs:NetworkInfo.MaximumNetworkInterfaces,IPv4PerENI:NetworkInfo.Ipv4AddressesPerInterface}' --output table --no-cli-pager
