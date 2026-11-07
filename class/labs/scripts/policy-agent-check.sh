#!/usr/bin/env bash
# Read-only live gate; not executed during source-package validation.
set -euo pipefail
source "$(dirname "$0")/common.sh"; ctx
PIN=$(get addon-vpc-cni)
[[ -n "$PIN" ]] || { echo 'No recorded CNI addon pin; stop/review.' >&2; exit 1; }
aws eks describe-addon --cluster-name "$STACK" --addon-name vpc-cni > "$STATE_DIR/policy-addon-live.json"
aws eks describe-addon-configuration --addon-name vpc-cni --addon-version "$PIN" > "$STATE_DIR/policy-addon-schema.json"
kubectl -n kube-system get daemonset aws-node -o json > "$STATE_DIR/policy-daemonset.json"
kubectl -n kube-system get pods -l k8s-app=aws-node -o json > "$STATE_DIR/policy-agent-pods.json"
kubectl get nodes -o json > "$STATE_DIR/policy-linux-nodes.json"
python3 "$LAB_ROOT/helpers/inspect_policy_agent.py" "$STATE_DIR/policy-addon-live.json" "$STATE_DIR/policy-addon-schema.json" "$STATE_DIR/policy-daemonset.json" "$STATE_DIR/policy-agent-pods.json" "$STATE_DIR/policy-linux-nodes.json" "$PIN" > "$STATE_DIR/policy-agent-gate.json"
AGENT=$(jq -r .container "$STATE_DIR/policy-agent-gate.json")
mapfile -t PODS < <(jq -r '.pods[]' "$STATE_DIR/policy-agent-gate.json")
for pod in "${PODS[@]}"; do kubectl -n kube-system logs "$pod" -c "$AGENT" --tail=100 > "$STATE_DIR/policy-agent-$pod.log"; done
cat_gate=$(jq -c '{gate,addonVersion,container,image,enforcementProven,next}' "$STATE_DIR/policy-agent-gate.json")
printf '%s\n' "$cat_gate"
echo 'Read-only prerequisites captured for every Linux node. Logs/config/readiness alone do NOT establish enforcement.'
