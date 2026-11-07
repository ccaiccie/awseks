# Audit alignment for class command/demo scenes

Independent source audit (2026-11-07 ~11:08 PST) FAIL for final lab sign-off with bounded fixes. Class teaches **corrected** operator sequences even while source scripts are still being updated.

## Keep (independently confirmed — do not revert)
- Conditional previous-minor EKS rollback within 7 days (eligibility constraints; not categorical no-downgrade).
- Auto Mode Gateway API with explicit CRD managed enablement; TLSRoute unverified.
- Auto Mode SecurityGroupPolicy on K8s >=1.36 with **eks.amazonaws.com/v1** (not Standard vpcresources transplant).
- LBC chart/appVersion v3.6.2 built against Gateway API v1.6.0; IAM policy hash corroborated.

## Corrected teaching sequences
### B1 — Namespace before namespaced dry-run
1. Apply Namespace (+ Pod Security labels) alone.
2. Wait until Namespace exists/Active.
3. Server dry-run remaining objects.
4. Apply remaining objects; rollout status.

### B2 — Controller-owned policy clients + separate evidence
- Create permitted/blocked clients as 1-replica Deployments (ownerReferences), wait Ready.
- Ingress deny: blocked→web timeout with agent evidence (not DNS-only failure).
- Egress deny: permitted-client → reachable non-allowed destination baseline, separate from ingress.
- DNS allow separately asserted (UDP+TCP 53).

### B3 — Incompatible add-ons BEFORE control-plane rollback
Gate/prepare: eligibility insights + readiness/skew + **downgrade incompatible add-ons first** → prepare nodes (Standard MNG/self-managed operator-owned; Auto Mode node rollback managed; Fargate replacement caveat) → control-plane rollback → verify apps/addons/controllers. Keep rollback feature; fix stage order.

### V1 — Discover policy agent
Inspect live DaemonSet containers/image/args (`--enable-network-policy`), readiness; do not hardcode container name alone (`aws-network-policy-agent` vs `aws-eks-nodeagent`).

### V2 — Dedicated 8080→8080 policy fixture
Keep F07/F08 ordinary Service 80→8080 DNAT lecture. For native-CNI policy acceptance tests use dedicated Service/direct Pod on 8080→8080 (or document version evidence for named-port).

## Honesty retained
- Expert EFS/Gateway/SGP/CA/Karpenter/IPv6/TLS/restore = guided objectives, not fully scripted/cloud-tested.
- Private API runner is external prerequisite, not provisioned by labs.
- Do not animate F03/F14/F15/F18 subordinate credential/image/provision exchanges as one serial packet.
- Source diagrams are conceptual boxes; class owns readable artwork/geometry.
