#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; owned_vpc
[[ "${DELETE_STACK:-}" == "$STACK" ]] || { echo "Destructive: set DELETE_STACK=$STACK after backup review." >&2; exit 1; }
echo "DESTROYS lesson LBs, app and PVC data in $STACK; controller and nodes must remain alive until finished."
kubectl -n eksclass delete ingress web-alb --ignore-not-found --wait=true --timeout=10m
kubectl -n eksclass delete service web-nlb --ignore-not-found --wait=true --timeout=10m
# In dedicated VPC, fail safely if ANY LB remains. No blind ELB deletion or finalizer removal.
for ((n=0;n<40;n++)); do
 COUNT=$(aws elbv2 describe-load-balancers --query "length(LoadBalancers[?VpcId=='$(get vpc)'])" --output text)
 [[ "$COUNT" == 0 ]] && break
 if (( n==39 )); then echo 'LB still present: inspect controller/finalizer/tags; leave nodes/controllers intact.' >&2; exit 1; fi
 # Bounded API waiter spacing is intentional, not a background-job polling loop.
 python3 -c "import time; time.sleep(15)"
done
# Delete exact lesson resources, not broad selectors or kube-system namespace.
kubectl -n eksclass delete hpa web --ignore-not-found
kubectl -n eksclass delete deployment volume-demo web --ignore-not-found --wait=true --timeout=5m
kubectl -n eksclass delete pod identity-check permitted-client blocked-client --ignore-not-found --wait=true --timeout=5m
kubectl -n eksclass delete pvc data --ignore-not-found --wait=true --timeout=10m
PV=$(get pv)
if [[ -n "$PV" ]]; then
 if kubectl get pv "$PV" >/dev/null 2>&1; then echo 'PV still exists: inspect reclaim/finalizers and disk backup before infrastructure deletion.' >&2; exit 1; fi
fi
kubectl delete namespace eksclass --ignore-not-found --wait=true --timeout=5m
kubectl delete storageclass eksclass-gp3 --ignore-not-found
kubectl delete ingressclass eksclass-alb --ignore-not-found
put app-cleaned yes
echo 'Check recorded EBS volume is deleted (or intentionally retained with cost documented) before stage91.'
