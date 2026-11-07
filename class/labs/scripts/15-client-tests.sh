#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
MODE=${1:-}
[[ "$MODE" == baseline || "$MODE" == enforce ]] || { echo 'Usage: 15-client-tests.sh baseline|enforce; baseline BEFORE stage12, enforce AFTER stage12 and convergence.' >&2; exit 1; }
image_guard "$DEBUG_IMAGE"; image_guard "$APP_IMAGE"
if [[ "$MODE" == baseline ]]; then
 put policy-baseline no
 put policy-applied no
fi
# Native CNI's documented controller ownership and equal-port prerequisites are deliberate.
python3 - "$LAB_ROOT/manifests/policy-fixture.yaml" "$DEBUG_IMAGE" "$APP_IMAGE" > "$STATE_DIR/policy-fixture.yaml" <<'PY'
import pathlib,sys
print(pathlib.Path(sys.argv[1]).read_text().replace('BUSYBOX_DIGEST_PLACEHOLDER',sys.argv[2]).replace('APP_DIGEST_PLACEHOLDER',sys.argv[3]))
PY
kubectl apply --dry-run=server -f "$STATE_DIR/policy-fixture.yaml"
kubectl apply -f "$STATE_DIR/policy-fixture.yaml"
for d in web permitted-client blocked-client egress-sink; do kubectl -n eksclass rollout status "deployment/$d" --timeout=300s; done
kubectl -n eksclass get pods -o json > "$STATE_DIR/policy-pods-current.json"
# Resolve one ready, controller-owned Pod per fixture role; never accept unready/no-IP endpoints.
python3 - "$STATE_DIR/policy-pods-current.json" > "$STATE_DIR/policy-targets-current.json" <<'PY'
import json,sys
items=json.load(open(sys.argv[1]))['items'];out={}
for key,label,value in [('web','app','web'),('sink','app','egress-sink'),('permitted','role','permitted-client'),('blocked','role','blocked-client')]:
 candidates=[p for p in items if p['metadata'].get('labels',{}).get(label)==value and not p['metadata'].get('deletionTimestamp') and any(c.get('type')=='Ready' and c.get('status')=='True' for c in p.get('status',{}).get('conditions',[]))]
 assert candidates, f'No ready {key} Pod'
 p=sorted(candidates,key=lambda p:p['metadata']['name'])[0]
 assert any(r.get('controller') and r.get('kind')=='ReplicaSet' for r in p['metadata'].get('ownerReferences',[])), f'{key}: missing Deployment/ReplicaSet ownership'
 assert p['status'].get('podIP'), f'{key}: no Pod address'
 out[key]={'name':p['metadata']['name'],'uid':p['metadata']['uid'],'ip':p['status']['podIP']}
print(json.dumps(out,indent=2))
PY
WEB_IP=$(jq -r .web.ip "$STATE_DIR/policy-targets-current.json")
SINK_IP=$(jq -r .sink.ip "$STATE_DIR/policy-targets-current.json")
PERMITTED=$(jq -r .permitted.name "$STATE_DIR/policy-targets-current.json")
BLOCKED=$(jq -r .blocked.name "$STATE_DIR/policy-targets-current.json")
fetch() { kubectl -n eksclass exec "$1" -- wget -T 5 -qO- "http://$2:8080/hostname"; }
# Positive DNS is separately asserted, not conflated with a denied HTTP connection.
kubectl -n eksclass exec "$PERMITTED" -- nslookup web-policy.eksclass.svc.cluster.local
kubectl -n eksclass exec "$BLOCKED" -- nslookup web-policy.eksclass.svc.cluster.local
if [[ "$MODE" == baseline ]]; then
 kubectl -n eksclass get networkpolicy -o json > "$STATE_DIR/policies-at-baseline.json"
 jq -e '.items|length==0' "$STATE_DIR/policies-at-baseline.json" >/dev/null || { echo 'Baseline requires this dedicated namespace to have NO NetworkPolicy. Review/remove exact lesson policies, not blind deletes.' >&2; exit 1; }
 fetch "$PERMITTED" "$WEB_IP" > "$STATE_DIR/baseline-permitted-web.log"
 fetch "$BLOCKED" "$WEB_IP" > "$STATE_DIR/baseline-blocked-web.log"
 fetch "$PERMITTED" "$SINK_IP" > "$STATE_DIR/baseline-permitted-sink.log"
 fetch "$BLOCKED" "$SINK_IP" > "$STATE_DIR/baseline-blocked-sink.log"
 fetch "$PERMITTED" web-policy.eksclass.svc.cluster.local > "$STATE_DIR/baseline-policy-service.log"
 cp "$STATE_DIR/policy-targets-current.json" "$STATE_DIR/policy-targets-baseline.json"
 put policy-baseline yes
 echo 'Baselines succeeded: both clients→ready direct web Pod, permitted→independent sink, equal-port Service and DNS. Next stage12, then enforce mode.'
else
 [[ "$(get policy-baseline)" == yes && "$(get policy-applied)" == yes ]] || { echo 'Need successful baseline and stage12 policy application first.' >&2; exit 1; }
 bash "$LAB_ROOT/scripts/policy-agent-check.sh"
 # Changed endpoint/client identities invalidate comparison: do not credit random network failure as policy.
 cmp "$STATE_DIR/policy-targets-baseline.json" "$STATE_DIR/policy-targets-current.json" || { echo 'Fixture identities/IPs changed; remove exact lesson policies and re-establish baselines.' >&2; exit 1; }
 fetch "$PERMITTED" "$WEB_IP" > "$STATE_DIR/enforce-permitted-web.log"
 fetch "$PERMITTED" web-policy.eksclass.svc.cluster.local > "$STATE_DIR/enforce-policy-service.log"
 # Sink still live via a NON-isolated client: failure of permitted→sink cannot be credited to dead sink.
 fetch "$BLOCKED" "$SINK_IP" > "$STATE_DIR/enforce-blocked-sink-control.log"
 # Verify exec process works independently, then require a timeout-like wget diagnostic for each negative.
 for client in "$PERMITTED" "$BLOCKED"; do kubectl -n eksclass exec "$client" -- sh -c 'exit 0'; done
 negative() {
  local client="$1" address="$2" log="$3"
  if fetch "$client" "$address" >"$STATE_DIR/$log" 2>&1; then echo "DENY FAILED: $log unexpectedly succeeded. Inspect enforcement; no pass." >&2; exit 1; fi
  python3 - "$STATE_DIR/$log" <<'PY'
import pathlib,sys
s=pathlib.Path(sys.argv[1]).read_text().lower()
assert 'timed out' in s or 'timeout' in s, 'Failure not identified as timeout; inspect exec/DNS/socket error. Do not count it as policy evidence.'
PY
 }
 negative "$BLOCKED" "$WEB_IP" enforce-ingress-deny.log
 negative "$PERMITTED" "$SINK_IP" enforce-egress-deny.log
 echo 'Observed positives plus independent ingress/egress timeout candidates recorded. LIVE SIGN-OFF STILL REQUIRES agent/PolicyEndpoint evidence and correlation; a timeout alone never proves policy cause.'
 echo 'Do not use original web:80→8080 Service as native-CNI policy acceptance; it remains the separate ordinary-DNAT lecture.'
fi
