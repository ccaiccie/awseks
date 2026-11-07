#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
# EKS metrics-server addon availability/version is discovered; it is not silently fetched latest from the Internet.
VER=$(addon_version metrics-server)
if [[ -z "$(get created-metrics-server)" ]]; then
 aws eks create-addon --cluster-name "$STACK" --addon-name metrics-server --addon-version "$VER" --tags "EksClassStack=$STACK"
 put created-metrics-server yes
fi
aws eks wait addon-active --cluster-name "$STACK" --addon-name metrics-server
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
kubectl apply -f "$LAB_ROOT/manifests/hpa.yaml"
kubectl -n eksclass get hpa web
# No synthetic load launched automatically. Build approved finite load, observe desired/current.
echo 'CPU utilization may initially be <unknown>. Inspect metrics and CPU requests, not increase max replicas blindly.'
echo 'HPA does NOT scale managed nodes. See guided CA/Karpenter objectives in README; node group remains 2..4.'
