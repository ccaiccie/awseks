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
