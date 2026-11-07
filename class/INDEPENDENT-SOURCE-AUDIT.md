# Independent EKS source-package audit

**Decision: FAIL for final lab/source sign-off — bounded fixes, not a curriculum rebuild.**
Audit cut: November 7, 2026, approximately 11:08 PST. Read-only review of the supplied source package; the only file written by this review is this report. No AWS commands, cluster deployment, repository checkout/change, account actions, browser UI, or final HTML playback were performed. The separate ccaiccie/awseks Terraform workstream is not reviewed or approved here.

## Material findings to fix before recording command demonstrations

### B1 — Fresh-install app stage validates a namespace without actually creating it
**Classification: confirmed sequencing defect by static/API semantics; not an observed cloud execution. Priority: high.**

- `labs/scripts/04-app.sh:9–10` performs server dry-run of the entire bundle and only then real apply, under `set -e`.
- `labs/manifests/app.yaml:1–7` defines the new `eksclass` Namespace; subsequent objects, starting at lines 9–14, use it. None of stages 00–03 creates this namespace.
- Server dry-run does not persist the Namespace. A multi-document apply is separate API requests, not a transaction with a shared speculative namespace. On a fresh cluster, namespaced dry-run requests therefore encounter a nonexistent namespace and prevent the subsequent real apply.

**Correction:** deliberately apply just the reviewed Namespace and its Pod Security labels first; wait until it exists/Active; then server-dry-run and apply the remaining objects. Preserve the existing context/account guards. Do not replace server validation wholesale with client-only validation. The first successful run must not depend on a leftover namespace from earlier testing.

**Evidence:** Kubernetes API concepts, “Single resource API” and “Dry-run”: https://kubernetes.io/docs/reference/using-api/api-concepts/#dry-run — dry-run has no persistence/side effects; kubectl submits a series of single-resource requests.

### B2 — NetworkPolicy exercise uses standalone clients outside the reliable enforcement fixture
**Classification: confirmed documented prerequisite omission; enforcement failure itself remains deployment-dependent. Priority: high for security teaching.**

- `labs/scripts/15-client-tests.sh:7–24` creates two bare Pods with no controller/ownerReferences.
- `labs/manifests/policies.yaml:19–35` selects `permitted-client` for egress isolation. This is taught as an exercised source-egress allow in F17 (`FLOW-SCENARIOS.json`, scenario begins at line 6812), `labs/README.md:26`, and Ch17.
- Current AWS network-policy considerations explicitly say enforcement is optimized for controller-owned Pods and **might not work reliably for standalone Pods without metadata.ownerReferences**. The allowed/blocked test can principally demonstrate destination Deployment ingress while failing to establish the source egress policy at all.
- The existing test checks only allowed→web plus blocked→web (`15-client-tests.sh:26–31`). That does not demonstrate denied egress from the isolated allowed client. Any wget failure also counts as the negative result; the explanatory echo is appropriately cautious but is not an enforcement assertion.

**Correction:** create permitted/blocked clients as one-replica Deployments (or another documented controller), wait for their Pods and execute through the controller/selected Pod. Keep source labels unchanged. Add an independent egress-denial test from permitted-client to a reachable, non-allowed destination with its own baseline; separately assert DNS works and use a ready direct Pod address to disambiguate destination-ingress denial. Preserve rollback and convergence caveats. Do not claim both ingress and egress enforcement from the existing two requests.

**Evidence, independently fetched live:** https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html, Considerations → Network Policies.

### B3 — Rollback diagram must prepare incompatible add-ons BEFORE control-plane rollback
**Classification: confirmed material runbook/flow omission, not an incorrect claim that rollback exists. Priority: medium.**

- F28 `FLOW-SCENARIOS.json:10745–10786`: gate → nodes → control-plane rollback → “Validate apps/addons”. The gate only states eligibility/features, while add-on checks are represented after the control-plane change.
- `TECHNICAL-SPEC.md:105` and `labs/EXPERT-COMMANDS.md:76` say nodes first and add-ons separately, but do not explicitly require incompatible add-ons to be downgraded first.
- The package's own `sources/S50.txt:75–78,298–306` and current live AWS rollback page require reviewing add-on compatibility and downgrading incompatible builds **before** rolling back the control plane. kube-proxy skew is among rollback readiness checks.

**Correction:** extend the existing eligibility/preparation stage to include rollback-readiness insights, application/controller/API compatibility, target-compatible add-ons and required add-on downgrade before the CP operation. Retain the final verification stage. State the compute variant: Standard MNG/self-managed preparation is operator-owned; Auto Mode node rollback is managed automatically; Fargate has its documented replacement caveat. No new topology is necessary—correct stage content/order.

**Evidence:** https://docs.aws.amazon.com/eks/latest/userguide/rollback-cluster.html, Summary and “Rollback and add-ons”.

## Version/implementation gates — do not report as observed deployment failures

### V1 — Discover the real policy-agent container; name/presence is not an enablement test

- `labs/scripts/12-policy.sh:5` hardcodes `.name=="aws-network-policy-agent"` and otherwise stops.
- `labs/EXPERT-COMMANDS.md:15` hardcodes the same name for logs.
- AWS prose in the supplied S12 does use that name, but the official current upstream DaemonSet manifest names the **container** `aws-eks-nodeagent` while its **image** is `amazon/aws-network-policy-agent`; the manifest can include it with `--enable-network-policy=false`.
- Therefore the current guard can reject a valid installation, and a matching name alone does not establish enforcement. The exact EKS-managed add-on build selected by the learner has not been inspected here.

**Correction:** inspect the live pinned add-on schema and rendered DaemonSet; discover the agent container from its documented image/args (or explicitly support the actual build's name), check enablement and readiness on nodes, then log that selected container and verify PolicyEndpoint/enforcement evidence. Do not blindly rename based on prose alone.

**Evidence:** https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/master/aws-k8s-cni.yaml (current manifest fetched read-only); https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy-configure.html. This is a concrete source discrepancy/version gate, not a claim of a live EKS-managed manifest.

### V2 — Native-CNI Service/port limitation must be reconciled in the policy fixture

Current AWS network-policy considerations say Service port must equal container port and named ports must use the same name. The primary Service is port80 → named `http`/Pod8080 (`labs/manifests/app.yaml:56,76`), while policy rules permit8080. Generic Kubernetes DNAT permits this Service mapping; that does not by itself establish native-CNI policy support for the chosen build. The package correctly avoids a universal before/after-NAT hook claim, but does not discuss this provider-specific limitation.

**Correction:** use a dedicated port8080→8080 Service/direct-Pod test for deterministic policy acceptance, or document version-specific evidence resolving the named-port case before promising the port80 policy test succeeds. Keep the ordinary Service-DNAT lecture (F07/F08) accurate; do not invent a VPC route or globally rewrite all Service examples.

Evidence: https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html, Considerations → Network Policies. This is an unresolved provider-compatibility gate, not proof that every 80→8080 mapping fails.

## Risky reported claims independently corroborated — KEEP, do not revert to stale advice

1. **Conditional previous-minor rollback within seven days is real in current AWS documentation.** Live rollback page matches S50. It requires an eligible in-place upgrade, initiating within seven days of completion, one previous minor, supported target/upgrade policy, ACTIVE cluster, compatible enabled features and readiness checks. Data is preserved, not restored to older etcd/app state. `--force` is not a default and cannot bypass basic eligibility. Do not replace this with categorical “EKS cannot downgrade.” Apply B3's preparation correction instead.
2. **Auto Mode Gateway API is documented.** https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-gateway-api.html matches S46: explicit cluster `elasticLoadBalancing.gatewayApi.crds.managed` enablement; separate `eks.amazonaws.com/gateway-alb` / `gateway-nlb` controllers. HTTPRoute/GRPCRoute/TCPRoute/UDPRoute are enumerated. Preserving the package's unverified Auto Mode TLSRoute caveat is correct.
3. **Auto Mode per-Pod SG support is version-sensitive, not categorically unsupported.** Current https://docs.aws.amazon.com/eks/latest/userguide/auto-networking.html confirms Kubernetes >=1.36. S11:29–34 identifies the distinct `eks.amazonaws.com/v1` SecurityGroupPolicy API/spec. Do not transplant Standard `vpcresources.k8s.aws` policy manifests. Auto Mode networking/CoreDNS distinctions are supported by the live page.
4. **LBC/chart3.6.2/Gateway API1.6.0 mapping is corroborated.** Live versioned https://kubernetes-sigs.github.io/aws-load-balancer-controller/v3.6/guide/gateway/gateway/ says built for Gateway API1.6.0; L4 TCP/UDP/TLS→NLB; L7 HTTP/GRPC→ALB. Actual chart fetched in-memory from https://aws.github.io/eks-charts/aws-load-balancer-controller-3.6.2.tgz has chartVersion3.6.2/appVersionv3.6.2 and SHA256 `9255bf39873b6cb31106dbe61dc87c3617bff4197783b5b94381811a13f99c3c`. The release IAM policy SHA256 also matches `16f232c9d9f79366fe949c4550ad517a202380058a9e48d45a4e215044a20a6a`. This confirms artifacts/documented compatibility, not cloud execution or every Gateway field.

## Flow, diagram, safety and completeness assessment

- Reviewed all29 main scenarios and eight subordinate exchanges. Parsed 37 draw.io pages /38 SVG XMLs (extra standalone architecture overview). Read actual five contact sheets covering the scenarios and individual F12, F13-1 and F24 PNGs. This is source geometry/semantic review, not final full-resolution HTML animation sign-off.
- No confirmed major packet-model defect found in reviewed core F04–F12/F24: Linux routing versus VPC lookup versus kernel Service DNAT/conntrack are separated; internal ClusterIP return rewrites to VIP; ALB uses two connections/XFF distinction; NLB IP TCP preservation is explicitly disabled, instance Local is separately scoped; CNI/node SNAT, NAT-private translation and actual IGW/EIP mapping are separate and reverse correctly.
- F03 ACK/watch/image exchanges, F14/F15 credential response versus signed app request, and F18 provisioning versus mount/data are separately modeled. The F13-1 note explicitly identifies node image-pull identity and default node SNAT for external S3. Do not turn those subordinate exchanges into one serial packet in the HTML builder. F16/F26 stop/return semantics are appropriately different from API403 F22.
- CLI account/cost/context/ownership guards, separate CNI/controller/workload/CSI roles, public /32 versus private SG, two-NAT routing, private-API runner confirmation, no unreviewed NAT removal, and ordered LB/PVC-before-controller teardown are substantially well scoped. CLI and Terraform ownership separation is explicit (`labs/README.md:58`, curriculum Ch24); no repo mutation was attempted.
- Novice→expert outline is broad and causally ordered. Expert EFS/Gateway/SGP/CA/Karpenter/IPv6/TLS/restore work remains **guided objectives**, not complete automation, as the source openly states. A tested private runner is an external prerequisite (`labs/README.md:23`), not provisioned by these scripts. The final README/class must retain that distinction; do not label every expert exercise “fully scripted/tested”. Repo Terraform completeness must be established by its separate implementer.
- Optional concise expert bridge: current native CNI Admin/Baseline ClusterNetworkPolicy tiers differ from additive ordinary namespace NetworkPolicy. The present ordinary-policy claims are correctly scoped; this is a coverage improvement, not another release blocker.
- Static parse/schema/rectangle results do not establish cloud acceptance, usable IAM under an SCP, current add-on schema, actual image compatibility, networking enforcement, HA/restore or final visual/narration quality. Source class assets are conceptual boxes by design; provider artwork, actual readable table builds, reserved bottom band, port-only packet motion, per-hop protocol state and final1080/930 review remain the HTML builder's responsibility.

## Minimum resolution for source sign-off

Fix B1 namespace bootstrap; fix B2 controller-owned policy clients and real egress/ingress evidence separation; fix B3 pre-rollback add-on preparation. Resolve V1/V2 against the selected add-on build or choose the documented conservative fixture. Retain the independently corroborated new AWS features rather than reverting them. Then repeat source/script review and label sandbox execution pending until it actually occurs.
