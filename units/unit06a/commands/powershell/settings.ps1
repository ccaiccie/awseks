# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
$AwsProfile = "REPLACE_WITH_YOUR_PROFILE"
$Region = "us-west-2"
$ExpectedAccount = "REPLACE_WITH_12_DIGITS"
$env:AWS_PAGER = ""
$env:AWS_CLI_AUTO_PROMPT = "off"
aws configure list-profiles
aws configure list --profile "$AwsProfile"
