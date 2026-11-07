#!/usr/bin/env bash
# Separate observations. One failed wget is not both ingress and egress enforcement.
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$DEBUG_IMAGE"; image_guard "$APP_IMAGE"

emit_client() {
  local name="$1"
  cat > "$STATE_DIR/$name.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  namespace: eksclass
spec:
  replicas: 1
  selector:
    matchLabels: {role: $name}
  template:
    metadata:
      labels: {role: $name}
    spec:
      automountServiceAccountToken: false
      securityContext: {runAsNonRoot: true, runAsUser: 1000, seccompProfile: {type: RuntimeDefault}}
      containers:
      - name: client
        image: $DEBUG_IMAGE
        command: [sh, -c, 'sleep 3600']
        securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
        resources: {requests: {cpu: 20m, memory: 16Mi}, limits: {cpu: 100m, memory: 64Mi}}
YAML
  kubectl apply -f "$STATE_DIR/$name.yaml"
  kubectl -n eksclass rollout status "deployment/$name" --timeout=180s
}

emit_other() {
  cat > "$STATE_DIR/other-dest.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: other-dest
  namespace: eksclass
spec:
  replicas: 1
  selector:
    matchLabels: {app: other}
  template:
    metadata:
      labels: {app: other}
    spec:
      automountServiceAccountToken: false
      securityContext: {runAsNonRoot: true, runAsUser: 1000, seccompProfile: {type: RuntimeDefault}}
      containers:
      - name: other
        image: $APP_IMAGE
        args: [netexec, --http-port=8080]
        ports: [{name: http, containerPort: 8080}]
        securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
        resources: {requests: {cpu: 20m, memory: 32Mi}, limits: {cpu: 200m, memory: 64Mi}}
YAML
  kubectl apply -f "$STATE_DIR/other-dest.yaml"
  kubectl -n eksclass rollout status deployment/other-dest --timeout=180s
}

pod_for() {
  kubectl -n eksclass get pod -l "$1" --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}'
}

# Success is a normal return. Failure is data, so it must not trip set -e.
connects() {
  local pod="$1" url="$2"
  kubectl -n eksclass exec "$pod" -- wget -T 5 -qO- "$url" >/dev/null 2>&1
}

emit_client permitted-client
emit_client blocked-client
emit_other
permitted="$(pod_for role=permitted-client)"
blocked="$(pod_for role=blocked-client)"
web="$(pod_for app=web)"
other="$(pod_for app=other)"
web_ip="$(kubectl -n eksclass get pod "$web" -o jsonpath='{.status.podIP}')"
other_ip="$(kubectl -n eksclass get pod "$other" -o jsonpath='{.status.podIP}')"
[[ -n "$permitted" && -n "$blocked" && -n "$web_ip" && -n "$other_ip" ]] || { echo 'Controller Pods are not Running.' >&2; exit 1; }

if kubectl -n eksclass get networkpolicy client-egress >/dev/null 2>&1; then
  mode=enforce
else
  mode=baseline
fi
echo "Mode: ${mode}. Clients are Deployments, not standalone Pods."

if ! kubectl -n eksclass exec "$permitted" -- nslookup web.eksclass.svc.cluster.local >/dev/null; then
  echo 'DNS from permitted-client failed. That is not an ingress result.' >&2
  exit 1
fi
echo 'DNS positive: permitted-client resolved web.eksclass.svc.cluster.local.'

direct_ok=0
direct_blocked=0
policy_ok=0
policy_blocked=0
other_from_permitted=0
other_from_blocked=0
connects "$permitted" "http://${web_ip}:8080/hostname" && direct_ok=1
connects "$blocked" "http://${web_ip}:8080/hostname" && direct_blocked=1
connects "$permitted" "http://web-policy.eksclass.svc.cluster.local:8080/hostname" && policy_ok=1
connects "$blocked" "http://web-policy.eksclass.svc.cluster.local:8080/hostname" && policy_blocked=1
connects "$permitted" "http://${other_ip}:8080/hostname" && other_from_permitted=1
connects "$blocked" "http://${other_ip}:8080/hostname" && other_from_blocked=1

echo "direct pod :8080 permitted=${direct_ok} blocked=${direct_blocked}"
echo "web-policy :8080 permitted=${policy_ok} blocked=${policy_blocked}"
echo "other-dest :8080 permitted=${other_from_permitted} blocked=${other_from_blocked}"
echo 'Service web :80 is the ordinary ClusterIP DNAT example. It is not this policy assertion.'

if [[ "$mode" == baseline ]]; then
  [[ "$direct_ok" == 1 && "$direct_blocked" == 1 && "$policy_ok" == 1 && "$policy_blocked" == 1 && "$other_from_permitted" == 1 && "$other_from_blocked" == 1 ]] || {
    echo 'Baseline is not fully reachable. Do not treat a later failure as policy enforcement.' >&2
    exit 1
  }
  echo 'Baseline recorded: direct Pod, port-8080 Service, and other-dest all answer before client-egress exists.'
  exit 0
fi

[[ "$direct_ok" == 1 && "$direct_blocked" == 0 ]] || { echo 'Direct Pod :8080 ingress result is not permitted-only.' >&2; exit 1; }
[[ "$policy_ok" == 1 && "$policy_blocked" == 0 ]] || { echo 'web-policy :8080 Service result is not permitted-only.' >&2; exit 1; }
[[ "$other_from_blocked" == 1 && "$other_from_permitted" == 0 ]] || {
  echo 'Egress result is not isolated. other-dest must stay reachable from blocked-client and fail from permitted-client.' >&2
  exit 1
}
echo 'Separate results: DNS allowed, direct Pod ingress permitted-only, web-policy Service permitted-only, permitted-client egress to other-dest denied.'
echo 'Established conntrack entries can outlive a new policy. These checks use fresh wget processes. They are not a packet capture.'
