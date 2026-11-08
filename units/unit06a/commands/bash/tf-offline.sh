# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
terraform -chdir=terraform/offline init -backend=false -input=false
terraform -chdir=terraform/offline fmt -check
terraform -chdir=terraform/offline validate
terraform -chdir=terraform/offline plan -input=false -out=offline.tfplan
# Optional LOCAL state/output write, no AWS calls or AWS resources:
terraform -chdir=terraform/offline apply -input=false offline.tfplan
terraform -chdir=terraform/offline output -json
