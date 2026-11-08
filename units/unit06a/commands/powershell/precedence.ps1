# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
Get-ChildItem Env:AWS_* | Select-Object -ExpandProperty Name
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
Remove-Item Env:AWS_ACCESS_KEY_ID,Env:AWS_SECRET_ACCESS_KEY,Env:AWS_SESSION_TOKEN,Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
