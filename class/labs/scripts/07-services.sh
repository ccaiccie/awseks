#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
[[ "$(get lbc-installed)" == yes ]] || { echo 'Install/check LBC first.' >&2; exit 1; }
kubectl apply --dry-run=server -f "$LAB_ROOT/manifests/alb-ip.yaml" -f "$LAB_ROOT/manifests/nlb-ip.yaml"
kubectl apply -f "$LAB_ROOT/manifests/alb-ip.yaml" -f "$LAB_ROOT/manifests/nlb-ip.yaml"
# API creation does not equal LB health; inspect ingress/service events and target health.
kubectl -n eksclass get ingress web-alb
kubectl -n eksclass get service web-nlb
kubectl -n eksclass describe ingress web-alb
aws elbv2 describe-load-balancers --query 'LoadBalancers[].{ARN:LoadBalancerArn,DNS:DNSName,Scheme:Scheme,State:State.Code}'
echo 'Only internal app LBs. Record EXACT ARNs after correlating Kubernetes stack tags; README explains health checks.'
