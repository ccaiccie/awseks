#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
kubectl -n kube-system get daemonset aws-node -o json > "$STATE_DIR/cni-before-policy.json"
jq -e '.spec.template.spec.containers[] | select(.name=="aws-network-policy-agent")' "$STATE_DIR/cni-before-policy.json" >/dev/null || { echo 'No enforcing network policy agent: STOP; manifest alone is not enforcement.' >&2; exit 1; }
echo 'WARNING: this deliberately blocks ALB/NLB backend traffic to web (only permitted-client Pods allowed).'
kubectl apply --dry-run=server -f "$LAB_ROOT/manifests/policies.yaml"
kubectl apply -f "$LAB_ROOT/manifests/policies.yaml"
kubectl -n eksclass describe networkpolicy web-from-client-only client-egress
echo 'Run fresh allowed/denied client connections per README L11 after policy convergence.'
echo "Rollback exact lesson policies: kubectl delete -f $LAB_ROOT/manifests/policies.yaml"
