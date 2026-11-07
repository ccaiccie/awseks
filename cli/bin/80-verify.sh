#!/usr/bin/env bash
# Read-only Kubernetes and AWS checks after kubeconfig exists.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd kubectl
require_cmd aws
assert_owned_cluster "${CLUSTER_NAME}"
require_context

info "Nodes:"
kubectl get nodes -o wide
ready="$(kubectl get nodes --no-headers | awk '$2=="Ready"{count++} END{print count+0}')"
[[ "${ready}" -ge "${NODE_MIN}" ]] || die "Fewer than ${NODE_MIN} nodes are Ready."

info "kube-system pods:"
kubectl get pods -n kube-system -o wide
kubectl rollout status deployment/coredns -n kube-system --timeout=180s
for ds in aws-node kube-proxy eks-pod-identity-agent ebs-csi-node; do
  kubectl rollout status "daemonset/${ds}" -n kube-system --timeout=180s
done

info "Cluster security group rules created by EKS (inbound self, outbound all, plus the EFA self rule):"
aws_cli ec2 describe-security-groups --group-ids "$(state_get CLUSTER_SG_ID)" \
  --query 'SecurityGroups[0].{IpPermissions:IpPermissions,IpPermissionsEgress:IpPermissionsEgress}' \
  --output json

info "Private route tables. A 0.0.0.0/0 route to a NAT is a VPC route. It is not Kubernetes Service routing."
IFS=',' read -r -a private_rts <<<"$(state_get PRIVATE_ROUTE_TABLE_IDS)"
aws_cli ec2 describe-route-tables --route-table-ids "${private_rts[@]}" \
  --query 'RouteTables[].Routes' --output json

checkpoint "verify-ok ready-nodes=${ready}"
info "Verification passed. Helm-based labs are still optional and are not part of this AWS CLI bootstrap."
