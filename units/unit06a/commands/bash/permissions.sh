# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws ec2 describe-availability-zones --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
aws eks describe-cluster-versions --profile "$AwsProfile" --region "$Region" --version-status STANDARD_SUPPORT --output json --no-cli-pager
# OPTIONAL administrator-assisted IAM policy simulation: replace with IAM role ARN, NOT STS session ARN
PolicySourceArn="REPLACE_WITH_IAM_ROLE_ARN"
aws iam simulate-principal-policy --profile "$AwsProfile" --region "$Region" --policy-source-arn "$PolicySourceArn" --action-names ec2:DescribeSubnets eks:DescribeClusterVersions --output json --no-cli-pager
