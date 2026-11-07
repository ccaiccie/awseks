#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
[[ "$(get policy-baseline)" == yes ]] || { echo 'Run 15-client-tests.sh baseline BEFORE policy application; independent reachability controls are required.' >&2; exit 1; }
bash "$LAB_ROOT/scripts/policy-agent-check.sh"
echo 'WARNING: intentionally blocks ALB/NLB backend traffic to web. Acceptance fixture uses separate web-policy:8080→8080, not original web:80→8080.'
kubectl apply --dry-run=server -f "$LAB_ROOT/manifests/policies.yaml"
kubectl apply -f "$LAB_ROOT/manifests/policies.yaml"
kubectl -n eksclass describe networkpolicy web-from-client-only client-egress
kubectl -n eksclass get policyendpoints.networking.k8s.aws -o json > "$STATE_DIR/policy-endpoints-observed.json"
jq -e '.items|length>0' "$STATE_DIR/policy-endpoints-observed.json" >/dev/null || { echo 'No managed PolicyEndpoint evidence yet; wait for convergence and rerun stage12. Do not edit/delete PolicyEndpoints.' >&2; exit 1; }
put policy-applied yes
echo 'Policy objects/managed endpoint records exist; this is NOT enforcement sign-off. Review target selection/agent evidence then run 15-client-tests.sh enforce for independent positives and negatives.'
echo "Rollback exact lesson policies: kubectl delete -f $LAB_ROOT/manifests/policies.yaml ; baseline evidence must be renewed afterward."
