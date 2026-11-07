#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$APP_IMAGE"
# Generate a reviewed, digest-pinned copy without editing the source manifest.
python3 - "$LAB_ROOT/manifests/app.yaml" "$APP_IMAGE" "$STATE_DIR/namespace.yaml" "$STATE_DIR/app-objects.yaml" <<'PY'
import pathlib, sys
source, image, namespace_path, rest_path = sys.argv[1:]
text = pathlib.Path(source).read_text().replace(
    "registry.k8s.io/e2e-test-images/agnhost:2.53", image
)
docs, current = [], []
for line in text.splitlines(keepends=True):
    if line.strip() == "---" and current:
        docs.append("".join(current))
        current = []
    else:
        current.append(line)
if current:
    docs.append("".join(current))
if not docs or "kind: Namespace" not in docs[0]:
    raise SystemExit("app.yaml must start with the eksclass Namespace document")
pathlib.Path(namespace_path).write_text(docs[0])
pathlib.Path(rest_path).write_text("".join(docs[1:]))
PY
# Server dry-run does not persist objects. Create the Namespace, including its
# Pod Security labels, and wait until it is Active before any namespaced request.
kubectl apply -f "$STATE_DIR/namespace.yaml"
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/eksclass --timeout=60s
kubectl get namespace eksclass -o json > "$STATE_DIR/namespace.json"
jq -e '.metadata.labels["pod-security.kubernetes.io/enforce"] == "restricted"' "$STATE_DIR/namespace.json" >/dev/null
kubectl apply --dry-run=server -f "$STATE_DIR/app-objects.yaml"
kubectl apply -f "$STATE_DIR/app-objects.yaml"
kubectl -n eksclass rollout status deployment/web --timeout=300s
kubectl -n eksclass get pods,service,endpointslices,pdb -o wide
printf '\nSeparate terminal (same kubeconfig):\nexport KUBECONFIG=%q\nkubectl -n eksclass port-forward service/web 8080:80\nThen curl http://127.0.0.1:8080/hostname ; Ctrl-C stops forwarding.\n' "$KUBECONFIG"
echo 'No ingress or public application load balancer created.'
