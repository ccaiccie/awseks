#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$APP_IMAGE"
# B1: namespace creation is a REAL separate API operation, not speculative dry-run state.
# Apply reviewed Pod Security labels first; no namespaced object can dry-run before it exists.
kubectl apply -f "$LAB_ROOT/manifests/namespace.yaml"
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/eksclass --timeout=60s
# Generate a reviewed, digest-pinned copy without editing the source manifest.
python3 - "$LAB_ROOT/manifests/app.yaml" "$APP_IMAGE" > "$STATE_DIR/app.yaml" <<'PY'
import pathlib,sys
print(pathlib.Path(sys.argv[1]).read_text().replace('registry.k8s.io/e2e-test-images/agnhost:2.53',sys.argv[2]))
PY
kubectl apply --dry-run=server -f "$STATE_DIR/app.yaml"
kubectl apply -f "$STATE_DIR/app.yaml"
kubectl -n eksclass rollout status deployment/web --timeout=300s
kubectl -n eksclass get pods,service,endpointslices,pdb -o wide
printf '\nSeparate terminal (same kubeconfig):\nexport KUBECONFIG=%q\nkubectl -n eksclass port-forward service/web 8080:80\nThen curl http://127.0.0.1:8080/hostname ; Ctrl-C stops forwarding.\n' "$KUBECONFIG"
echo 'No ingress or public application load balancer created.'
