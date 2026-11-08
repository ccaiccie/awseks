# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
# Choose ONLY the logout matching the method you used:
aws logout --profile "$AwsProfile"
# IAM Identity Center alternative, affects all cached SSO sessions:
aws sso logout
# Local state inventory; no cloud deletion:
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
