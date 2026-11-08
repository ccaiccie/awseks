# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
$ActualAccount = aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --query Account --output text --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw "Identity request failed" }
if ($ActualAccount -ne $ExpectedAccount) { throw "STOP: wrong account" }
