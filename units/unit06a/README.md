# Unit 6A r4 — before the cloud, with full commands and Terraform

For network engineers with no assumed Linux, container or EKS experience. Start here on **your own computer**. No AWS actions were executed by the lesson builder. The default practice path creates no AWS infrastructure. Do not run a whole command-reference file blindly: read and execute one step at a time.

## Start in this order
1. Extract the ZIP to a private folder, e.g. Downloads/unit06a. Open Terminal (Bash) on macOS/Linux, or PowerShell on Windows. In your file manager open that folder; use its “open in terminal” action, or type `cd` followed by the full folder path in quotes. Bash example: `cd "$HOME/Downloads/unit06a"`; PowerShell example: `Set-Location "$HOME/Downloads/unit06a"`. Your actual extracted path may differ.
2. Run `pwd` / `Get-Location` and `ls` / `Get-ChildItem`. Confirm this README, scripts/ and terraform/ are present. A relative path starts from this folder. A command block is not a console search query. Do not type prompt characters or explanatory sample output.
3. Read INSTALL.md, install only tools you lack and confirm local versions. No cluster or Docker is needed for Unit 6A. Python scripts use only its standard library; jq is not required.
4. Read API-SERVICE-FOUNDATIONS.md for API endpoint/Service-pool meaning, then AUTH.md and PERMISSIONS.md with your AWS administrator. Obtain an approved sandbox/account/Region and a temporary non-root principal. Do not assume access to production. Choose ONE authentication path.
5. Follow FOLLOW-ALONG.md in lecture order. Every accepted scene has a complete Bash and PowerShell command block, flag/value explanations, illustrative output, checks, likely errors, Terraform match and a practice exercise. Blank/empty inventory before Unit 6B is normal.
6. Terraform comes in two complete projects. `terraform/offline/` calculates the plan without AWS. `terraform/read-only/` optionally authenticates to read identity/AZs/type limits/EKS versions/subnets and optionally selected VPC DNS flags, route tables, NAT gateways, internet gateways and existing clusters. No resource blocks, no infrastructure creation, separate local states. Read the entire plan before optional data-only apply, which writes local state/outputs. Do not run Terraform in another lab directory.
7. Leave CostAck=NO. OPTIONAL-BUDGET.md is a separate, explicitly opt-in monitoring-budget/account-mutation path. It is NOT a spending cap. No cluster/VPC/NAT/node creation commands are included; Unit 6B owns that billable build.
8. Finish with CLEANUP.md. Logging out does not stop cloud charges. Never delete discovered resources or run a blind terraform destroy.

## Public matching practice baseline — PR #4, not merged

The practice-source baseline is public on branch `cursor/unit06a-practice-source-8b45` at immutable commit `189a683034edae19820ced02d2f11915b1fa0d81`. PR: https://github.com/ccaiccie/awseks/pull/4. This does NOT claim a merge into main. This local amendment updates links/provenance only; its metadata edits await parent publication/review. Lessons, audio and videos remain private.

- Source folder: https://github.com/ccaiccie/awseks/tree/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a
- README: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/README.md
- Student follow-along: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/FOLLOW-ALONG.md
- Lecture/practice map: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/C4-LECTURE-PRACTICE-MAP.md
- Command/Terraform map: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/LECTURE-COMMAND-TERRAFORM-MAP.md
- Offline Terraform: https://github.com/ccaiccie/awseks/tree/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/terraform/offline
- Read-only Terraform: https://github.com/ccaiccie/awseks/tree/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/terraform/read-only

Links intentionally target the already public 97-payload technical baseline, not a hypothetical future commit containing this link amendment.

## Files / confidentiality
- FOLLOW-ALONG.md: per-lecture tutorial, all full HCL files, commands and explanations.
- LECTURE-COMMAND-TERRAFORM-MAP.md: every lecture → command → Terraform/practice.
- commands/bash/ and commands/powershell/: same full commands, one topic per reference file. Read prerequisites before copying; do not execute every file as a batch.
- scripts/network_checks.py and scripts/check_guard.py: offline calculations and rehearsal gates, never AWS APIs.
- terraform/offline/ and terraform/read-only/: complete .tf files + non-secret `.tfvars.example` samples.
- legacy-offline/: accepted offline plan/fixtures for comparison; not the main hidden-helper workflow.
- examples/: complete optional budget JSON. Replace email locally only.
- SOURCES.md, CLI-TERRAFORM-BOUNDARIES.md, CLEANUP.md, OPTIONAL-BUDGET.md, INSTALL.md, AUTH.md, PERMISSIONS.md.

REPLACE values must be edited locally. Example account numbers, dates, names, addresses and outputs are NOT actual account results. Never share credentials, cache files, local .tfvars, state, plans, logs, email subscriber lists or the private worksheet. The HCL and lock files themselves contain no credentials. `.gitignore` is defense in depth, not a substitute for review.

## ALB spelled out before address planning
ALB means **Application Load Balancer**: a layer-seven HTTP/HTTPS entry point. Follow listener → host/path rule → target group → target health with the full optional read commands in the ALB section of FOLLOW-ALONG.md. EKS IP target mode and instance/NodePort target mode are alternatives. This unit reserves subnet headroom and inspects authorized existing objects only; it does not create an ALB.

## Revised complete command follow-along
Use `INSTALL.md` for the COMPLETE selected OS path: actual CPU assignment, download, publisher/integrity failure gates and installation are all shown, including full macOS Terraform. Stop at every failed check. `OPTIONAL-BUDGET.md` is a separately authorized mutation path with fresh unique name bound into private JSON, private subscriber copies, collision-vs-denial check, fresh account identity, write-once original ownership and live generation checks before cleanup. Default Unit6A remains observation/data-only; this does not create an EKS cluster.

`C4-LECTURE-PRACTICE-MAP.md` maps every revised scene to the visible command/HCL source and its interpreted output/effect. Full Terraform files remain under terraform/offline and terraform/read-only; data-only apply writes private local state but creates no AWS infrastructure. Never commit state/plans/private input or subscriber records. Use ONE OS path and ONE infrastructure owner.

Matching public follow-along baseline: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/FOLLOW-ALONG.md . Lecture/practice map: https://github.com/ccaiccie/awseks/blob/189a683034edae19820ced02d2f11915b1fa0d81/units/unit06a/C4-LECTURE-PRACTICE-MAP.md . Public PR #4 is not merged; this local metadata amendment is not yet uploaded. Lessons/audio/videos remain private.

## C5 query-specific follow-along correction
C4-LECTURE-PRACTICE-MAP.md retains its legacy filename but is regenerated from C5 lecture source. Selected NAT/ENI/ALB/DNS/Kubernetes fields, captured-versus-printed values, local membership results, and the alternative SSO setup/login effects now match each actual page. Executable commands/HCL are unchanged from safety-reviewed C4. The matching technical practice baseline is now public at commit 189a683034edae19820ced02d2f11915b1fa0d81 (PR #4, not merged); this local link/provenance amendment awaits review/publication.

## C6 card-only correction
The selected-subnet placement pages now distinguish ID/AZ/CIDR observations from the earlier free-IP capacity query and troubleshoot DescribeSubnets/--filters. Code, current narration, all audio, diagrams, cue timing and player behavior are unchanged from C5. The legacy-named C4-LECTURE-PRACTICE-MAP.md contains the corrected current cards.
