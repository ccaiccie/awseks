# Validation record — corrected source v2 only

Research/build date November 7, 2026 (PST). **No AWS deployment, login, account read, API mutation, cloud cost, repository edit or publication performed.** Commands below execute only local parsing/rendering/public-source fetching. VALIDATION-RESULTS.json records final automated outcomes.

## Actually performed
- `bash -n` on all21 shell files: PASS. Merely parsed, never sourced/executed a lab script.
- ShellCheck warning-or-higher on21 scripts: PASS, no findings. This is not proof of AWS/API/IAM correctness.
- PyYAML loaded19 static manifest objects +1 generated Pod heredoc object:20, unique identities/basic required fields PASS.
- All20 objects validated against pinned Kubernetes1.36.0 **strict standalone schemas from community-derived Kubernetes JSON schema mirror**, exact URLs and hashes in sources/k8s-schemas/index.json. PASS; no server contacted, no CRD/live admission proof.
- FLOW-SCENARIOS.json validated against included JSON Schema and custom checks:29 scenario IDs, actor references, forward/return order/stop paths and real-route owner/association/destination/candidate/winner fields PASS.
- Geometry:138 explicit orthogonal inter-device segments including subordinate message flows; matching named boundary ports; unrelated node rectangles +20px clearance; topology within y140..620 and bottom band y660..884 for930px height PASS. These checks don't cover actual font glyph bounds, arrowhead dimensions, icons, final motion radius or all active state labels.
- draw.io XML:37 flow pages incl8 subordinate-connection pages; valid IDs/parents/source/target references and explicit ports/waypoints PASS. Diagram editor GUI import was NOT tested. Conceptual source boxes, not AWS-stencil certification.
- SVG XML:38 files (37flows + architecture) PASS; rendered38 source PNGs and contact sheets with CairoSVG. Contact sheets reviewed, F12 sampled full-size in v1; corrected F28 sampled full-size in v2; identified and fixed slash-delimited label overflow in v1; v2 explicitly shows addon downgrade before CP; round-trip subflow lanes separated. This is a **static source review**, not full per-scenario browser/animation/audio review or two-viewport final artifact sign-off.
-69 public documentation/source snapshots fetched, nonempty and indexed with hashes. Controller chart3.6.2→appVersionv3.6.2 and IAM policy verified against public release/index artifacts. Chart digest9255bf39873b6cb31106dbe61dc87c3617bff4197783b5b94381811a13f99c3c. Policy digest16f232c9d9f79366fe949c4550ad517a202380058a9e48d45a4e215044a20a6a.

## Reproduce local checks
```bash
python3 -m venv --system-site-packages /tmp/eksclass-validate
/tmp/eksclass-validate/bin/pip install -r tools/requirements.txt
/tmp/eksclass-validate/bin/python tools/build_flows.py
/tmp/eksclass-validate/bin/python tools/validate_local.py
/tmp/eksclass-validate/bin/python -c 'import json,jsonschema; jsonschema.validate(json.load(open("FLOW-SCENARIOS.json")),json.load(open("FLOW-SCENARIOS.schema.json")))'
/tmp/eksclass-validate/bin/python tools/render_diagrams.py
```
ShellCheck must be installed separately. `fetch_sources.py` optionally refreshes public docs and overwrites source snapshots/index, so retain this dated copy before refreshing; updates may change assumptions. Render helper needs system Cairo. No AWS CLI/kubectl/Helm executable is required for these local checks. Local default Python environment lacked jsonschema/CairoSVG; an isolated venv was installed instead of changing the managed system environment.

## Not performed — acceptance gates before claiming a working deployment
AWS CLI/kubectl/Helm were not installed or run as part of this research. All live outputs are expressly illustrative shapes, not captured evidence. Still required in an authorized sandbox:
1. Fill account/role/region/public /32 and reviewed image digests; validate temporary identity, policy boundary/PassRole/service-linked roles, regional AZ/version/quota/AMI/capacity availability and costs.
2. Review exact discovered addon versions and their config schemas (`describe-addon-configuration`); validate chosen kube-proxy runtime mode after startup; confirm supported image platform/SDK chain and controller chart rendering.
3. Exercise EKS create/access/bootstrap, private workers/NAT, Pod Identity CNI/LBC/workload/CSI roles, addon/node waiters, app readiness/DNS/Service forward+return, LB health and private network reachability. Check generated SG behavior and webhook9443.
4. Run server-side kubectl dry-run/admission checks, allowed/denied fresh network connections with agent evidence, correct endpoint/source-NAT/S3 routing observation, CSI topology and actual persistence test, HPA metrics/capacity behavior.
5. Test private endpoint transition+recovery with already proven runner/VPN path. Never lock out sole administration path.
6. Checkpoint creation stages can reuse recorded IDs in ordinary serial reruns; they are not general drift reconciliation. Unknown-response timeout recovery and destructive partial cleanup require manual exact-resource review; **do not claim fully idempotent lifecycle orchestration**.
7. Verify ordered teardown removes LB/PVC resources while controllers/nodes run, respects protected data/retained logs, waits for managed ENIs, and leaves no unintended billable resources. Do not remove finalizers or force-delete unknown ENIs.
8. Optional expert extensions need their own supported-version/IAM/network manifests and cloud acceptance; research/runbooks are not substitutes for EFS/Gateway/SGP/IPv6/CA/Karpenter/upgrade/restore test evidence.
9. Presentation build still needs final genuine AWS artwork/provenance, male audio/transcripts, all route/service/policy progressive card states, browser whole-class playback, per-scenario forward/return/deny screenshots at1920×930/1080, audio/MP4 decode/sync checks if later requested. No HTML/voice/MP4 was built in this phase.

## v2 independent-audit correction regression record
- Read INDEPENDENT-SOURCE-AUDIT.md in full; original contents preserved and hash checked. B1/B2/B3 implemented; V1/V2 use documented conservative gates/fixture, not claims of observed EKS runtime failures.
-19 synthetic/local regression tests PASS (tools/test_audit_regressions.py), including alternate actual agent container name, false/missing enable flag, unknown image, pin drift, schema support, incomplete readiness/ownership/node coverage, Namespace ordering, distinct equal-port policy fixture, independent positive/negative controls and addon-before-CP model ordering. No shell lab or cloud API was executed by these tests.
- Full source-only static suite rerun after changes:21shell scripts,20Kubernetes YAML objects,29scenarios,138segments,37draw.io flow pages,38SVGs, formal flow schema. Current machine-readable findings in VALIDATION-RESULTS.json.
- INDEPENDENT-SOURCE-AUDIT.md remains the original FAIL review, not rewritten as approval. AUDIT-RESOLUTION.md is implementation evidence for a fresh independent re-review. Runtime acceptance remains pending.
- class/ belongs to the active separate builder: excluded from source validation/inventory/ZIP and not modified by this correction task. Repository code likewise untouched. New v2 ZIP preserves original v1 ZIP; no external upload or publication.
