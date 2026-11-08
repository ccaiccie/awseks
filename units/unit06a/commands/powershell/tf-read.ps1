# Reference commands. Read FOLLOW-ALONG.md first. Run ONE step at a time on YOUR computer.
# Set settings/identity first for AWS reads. REPLACE values are mandatory.
Copy-Item terraform/read-only/terraform.tfvars.example terraform/read-only/terraform.tfvars
# EDIT that copy in your text editor: profile, Region and intended account ID
terraform -chdir=terraform/read-only init -backend=false -input=false
terraform -chdir=terraform/read-only fmt -check
terraform -chdir=terraform/read-only validate
terraform -chdir=terraform/read-only plan -input=false -out=observations.tfplan
# Optional reviewed data-only plan writes LOCAL state; no AWS resources created
terraform -chdir=terraform/read-only apply -input=false observations.tfplan
terraform -chdir=terraform/read-only output -json
