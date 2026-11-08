# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
SubnetId="REPLACE_WITH_EXISTING_SUBNET_ID"
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=association.subnet-id,Values=$SubnetId" --output json --no-cli-pager
# If no explicit association was returned, consult this VPC main table:
aws ec2 describe-route-tables --profile "$AwsProfile" --region "$Region" --filters "Name=vpc-id,Values=$VpcId" Name=association.main,Values=true --output json --no-cli-pager
python3 scripts/network_checks.py --destination 10.42.33.7
python3 scripts/network_checks.py --destination 203.0.113.80
