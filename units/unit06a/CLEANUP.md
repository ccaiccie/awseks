# Exact cleanup scope

Default Unit 6A creates no AWS infrastructure. Do not delete any VPC, subnet, ENI, SG, route, NAT, EIP, volume or cluster just because a read command listed it. Unit 6B has a separately owned billable lifecycle. Logout does not stop bills.

If used console-login: `aws logout --profile YOUR_ACTUAL_PROFILE` (replace YOUR_ACTUAL_PROFILE). If used Identity Center instead: `aws sso logout` (all cached SSO sessions, consider other work). Neither is cloud cleanup.

## Optional local output/state cleanup, ONLY these data-only projects
First verify .tf files contain no resource/module/import blocks and `terraform -chdir=terraform/read-only state list` lists only `data.` entries, if state exists; offline state has no resource entries. If anything else appears STOP and investigate the project owner. Do not apply this procedure to managed-resource state.

From the unit06a folder, after reviewing those exact paths:
```bash
rm -f terraform/offline/offline.tfplan terraform/offline/terraform.tfstate terraform/offline/terraform.tfstate.backup
rm -f terraform/read-only/observations.tfplan terraform/read-only/terraform.tfstate terraform/read-only/terraform.tfstate.backup
```
PowerShell, same exact local files:
```powershell
Remove-Item terraform/offline/offline.tfplan,terraform/offline/terraform.tfstate,terraform/offline/terraform.tfstate.backup -ErrorAction SilentlyContinue
Remove-Item terraform/read-only/observations.tfplan,terraform/read-only/terraform.tfstate,terraform/read-only/terraform.tfstate.backup -ErrorAction SilentlyContinue
```
These commands remove local observations/plans, NOT AWS objects. No terraform destroy is needed or included. Keep source .tf files and .terraform.lock.hcl. Keep your private configuration/worksheet secure for Unit 6B or remove its exact local file when no longer needed; do not commit it. Do not delete credential caches manually.

Optional budget: only if YOU created the named dedicated budget through OPTIONAL-BUDGET.md and recorded ownership, use its reviewed delete-budget command. Keep a deliberate useful alert if desired; never delete a pre-existing/shared budget. Any separately created resources need their own authorized cleanup and post-delete cost/inventory verification, not these local state removal commands.
