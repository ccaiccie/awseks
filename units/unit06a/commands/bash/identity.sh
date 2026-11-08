# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
ActualAccount=$(aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager) || exit 1
if [ "$ActualAccount" != "$ExpectedAccount" ]; then printf '%s
' 'STOP: wrong account'; exit 1; fi
