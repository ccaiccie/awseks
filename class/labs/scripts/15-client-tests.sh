#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$DEBUG_IMAGE"
for client in permitted-client blocked-client; do
 cat > "$STATE_DIR/$client.yaml" <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: $client
  namespace: eksclass
  labels: {role: $client}
spec:
  restartPolicy: Never
  automountServiceAccountToken: false
  securityContext: {runAsNonRoot: true, runAsUser: 1000, seccompProfile: {type: RuntimeDefault}}
  containers:
  - name: client
    image: $DEBUG_IMAGE
    command: [sh, -c, 'sleep 3600']
    securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
    resources: {requests: {cpu: 20m, memory: 16Mi}, limits: {cpu: 100m, memory: 64Mi}}
YAML
 kubectl apply -f "$STATE_DIR/$client.yaml"
 kubectl -n eksclass wait --for=condition=Ready "pod/$client" --timeout=180s
done
kubectl -n eksclass exec permitted-client -- nslookup web.eksclass.svc.cluster.local
kubectl -n eksclass exec permitted-client -- wget -T 5 -qO- http://web.eksclass.svc.cluster.local/hostname
if kubectl -n eksclass exec blocked-client -- wget -T 3 -qO- http://web.eksclass.svc.cluster.local/hostname; then
 echo 'DENY TEST FAILED: connectivity allowed. If policies not yet installed, expected baseline; after stage12 STOP and inspect enforcement.' >&2; exit 1
else
 echo 'Denied client connection did not succeed. Check timeout reason + policy-agent evidence; DNS errors alone do not prove ingress deny.'
fi
