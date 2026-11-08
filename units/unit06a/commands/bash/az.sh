# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --filters Name=zone-type,Values=availability-zone --query 'AvailabilityZones[].{Name:ZoneName,ID:ZoneId,State:State,OptIn:OptInStatus}' --output table --no-cli-pager
