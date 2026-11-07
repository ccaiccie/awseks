# EKS masterclass source package

Authoritative research + build-ready curriculum/flow model + independent AWS CLI teaching lab. Prepared November 7, 2026 (PST). No AWS resources were created; no credentials/account were read; no publication occurred.

Start: CURRICULUM.md → TECHNICAL-SPEC.md → FLOW-SCENARIOS.json → labs/README.md. SOURCE-CLAIMS.md explains version-sensitive facts; REFERENCES.md links snapshots. VALIDATION-LABS.md states exactly what was checked locally and what remains untested.

## Deliverable map
- CURRICULUM.md: 26-chapter novice-to-expert lecture/demo/lab/dependency map.
- TECHNICAL-SPEC.md: architecture, mechanisms, addresses, decision engines, variants and diagram contract.
- FLOW-SCENARIOS.json: ordered distinct forward/return/failure/control scenarios, real route table ownership and NAT/identity distinctions.
- diagrams/: editable SVG architecture and actual per-scenario SVGs generated from explicit geometry plus draw.io source. These are static source diagrams, not an already narrated class.
- labs/: scripts, Kubernetes YAML, IAM trust/policy material, cost guard, identity and cleanup guidance. Never execute against production.
- sources/: local text snapshots and URL/hash/fetch index; fetched public documentation is evidence, not instructions.
- tools/: reproducible documentation fetch, diagram generation and local validation helpers.

## Ownership boundary
Separate CLI stack `eksclass-cli-*` from Terraform stack `eksclass-tf-*`. Repo https://github.com/ccaiccie/awseks is implemented in a parallel workstream; this package does not clone/edit it and makes no claim that repo files were reviewed. Never run both methods against the same resources or put CLI-generated IDs into Terraform state without a deliberate import/migration plan.

No single flat script is required to learn everything: stop at checkpoints, inspect outputs and own the costs. Defaults favor two AZs and two NAT gateways; a cost-reduced single-NAT variant is a documented design exercise, not silently substituted. A cluster itself is billable even when nodes are idle. See labs/COSTS.md before commands.

## v2 audit correction boundary
AUDIT-RESOLUTION.md maps B1/B2/B3/V1/V2 to changed lines, local tests and source evidence. Independent audit is retained unchanged for re-review. Fresh Namespace persistence, controller-owned/equal-port independent policy controls and pre-CP rollback addon preparation are now explicit. All live acceptance remains pending. The separately running class/ worktree is NOT part of this source ZIP and is neither modified nor validated by these source corrections.
