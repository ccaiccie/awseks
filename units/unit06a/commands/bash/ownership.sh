# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
terraform -chdir=terraform/offline state list
terraform -chdir=terraform/read-only state list
