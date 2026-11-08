# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
python3 -c 'import os; print("\n".join(sorted(k for k in os.environ if k.startswith("AWS_"))))' || exit 1
aws configure list --profile "$AwsProfile"
# Only if stale manual environment keys are unintended in this shell:
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
aws sts get-caller-identity --profile "$AwsProfile" --region "$Region" --output json --no-cli-pager
