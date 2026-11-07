#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
kubectl -n kube-system get daemonset aws-node -o json > "$STATE_DIR/cni-before-policy.json"
# The managed build selects the container. A hardcoded name is not the test:
# upstream has used container name aws-eks-nodeagent with image amazon/aws-network-policy-agent,
# and that container can be rendered with --enable-network-policy=false.
python3 - "$STATE_DIR/cni-before-policy.json" "$STATE_DIR/policy-agent.json" <<'PY'
import json, pathlib, sys
doc = json.loads(pathlib.Path(sys.argv[1]).read_text())
spec = doc["spec"]["template"]["spec"]
found = []
for key in ("initContainers", "containers"):
    for container in spec.get(key) or []:
        image = container.get("image") or ""
        args = [str(item) for item in container.get("args") or []]
        blob = " ".join(args)
        if (
            "aws-network-policy-agent" in image
            or "enable-network-policy" in blob
            or container.get("name") in {"aws-network-policy-agent", "aws-eks-nodeagent"}
        ):
            found.append({"list": key, "name": container.get("name"), "image": image, "args": args, "env": container.get("env") or []})
if len(found) != 1:
    names = [item["name"] for item in found] or [
        item.get("name") for item in spec.get("containers") or []
    ]
    raise SystemExit(f"Could not select exactly one network-policy agent container. Saw {names}.")
pathlib.Path(sys.argv[2]).write_text(json.dumps(found[0], indent=2))
print(found[0]["name"])
PY
agent_name="$(jq -r .name "$STATE_DIR/policy-agent.json")"
agent_args="$(jq -r '[.args[]] | join(" ")' "$STATE_DIR/policy-agent.json")"
if [[ "$agent_args" == *'enable-network-policy=false'* ]]; then
  echo "Agent container ${agent_name} is rendered with network policy disabled." >&2
  exit 1
fi
enabled=false
if [[ "$agent_args" == *'enable-network-policy=true'* ]]; then
  enabled=true
fi
config_values="$(aws eks describe-addon --cluster-name "$STACK" --addon-name vpc-cni --query 'addon.configurationValues' --output text || true)"
if printf '%s' "$config_values" | jq -e '(.enableNetworkPolicy == true) or (.enableNetworkPolicy == "true")' >/dev/null 2>&1; then
  enabled=true
fi
if [[ "$enabled" != true ]]; then
  echo "Network policy is not enabled on ${agent_name}. A matching name is not enforcement." >&2
  exit 1
fi
ready="$(kubectl -n kube-system get daemonset aws-node -o jsonpath='{.status.numberReady}')"
desired="$(kubectl -n kube-system get daemonset aws-node -o jsonpath='{.status.desiredNumberScheduled}')"
[[ "$ready" == "$desired" && "$ready" != "0" ]] || { echo "aws-node is not ready on every node (${ready}/${desired})." >&2; exit 1; }
kubectl get crd policyendpoints.networking.k8s.aws >/dev/null
echo "Using agent container ${agent_name}. Logs: kubectl -n kube-system logs daemonset/aws-node -c ${agent_name} --tail=100"
echo 'WARNING: this deliberately blocks ALB/NLB backend traffic to web (only permitted-client Pods allowed).'
kubectl apply --dry-run=server -f "$LAB_ROOT/manifests/policies.yaml"
kubectl apply -f "$LAB_ROOT/manifests/policies.yaml"
kubectl -n eksclass describe networkpolicy web-from-client-only client-egress
# PolicyEndpoint objects are the enforcement objects. An empty list is not success.
for _ in 1 2 3 4 5 6; do
  count="$(kubectl get policyendpoints -A --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  [[ "${count}" != "0" ]] && break
  sleep 5
done
[[ "${count}" != "0" ]] || { echo 'No PolicyEndpoint objects after apply. The manifest is not evidence of enforcement.' >&2; exit 1; }
echo 'Run 15-client-tests.sh for separate DNS, direct-Pod ingress, and egress checks.'
echo "Rollback exact lesson policies: kubectl delete -f $LAB_ROOT/manifests/policies.yaml"
