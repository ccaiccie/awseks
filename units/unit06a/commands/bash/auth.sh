# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
# PATH A: CLI 2.32.0+; approved non-root principal with SignInLocalDevelopmentAccess
aws login --profile "$AwsProfile" --region "$Region"
# PATH B instead: IAM Identity Center; use your organization-provided values interactively
aws configure sso --profile "$AwsProfile"
aws sso login --profile "$AwsProfile"
