#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; owned_vpc
[[ "${DELETE_STACK:-}" == "$STACK" && "$(get app-cleaned)" == yes ]] || { echo 'Run stage90 and explicitly confirm DELETE_STACK.' >&2; exit 1; }
[[ "${DISK_DELETION_REVIEWED:-NO}" == YES ]] || { echo 'Verify recorded EBS/PV deletion/retention before setting DISK_DELETION_REVIEWED=YES.' >&2; exit 1; }
ctx
if [[ "$(get lbc-installed)" == yes ]]; then helm uninstall aws-load-balancer-controller -n kube-system --wait --timeout 10m; put lbc-installed no; fi
# Remove addon controllers that manage disks only after all PVC/PV cleanup.
for addon in metrics-server aws-ebs-csi-driver; do
 if [[ "$(get "created-$addon")" == yes ]]; then
  aws eks delete-addon --cluster-name "$STACK" --addon-name "$addon"
  aws eks wait addon-deleted --cluster-name "$STACK" --addon-name "$addon"
  put "created-$addon" deleted
 fi
done
# Delete explicit custom associations; addon-owned CNI associations go with addon deletion.
for k in workload-association lbc-association; do
 ID=$(get "$k"); if [[ -n "$ID" && "$ID" != deleted ]]; then aws eks delete-pod-identity-association --cluster-name "$STACK" --association-id "$ID"; put "$k" deleted; fi
done
aws eks delete-nodegroup --cluster-name "$STACK" --nodegroup-name "$STACK-ng"
aws eks wait nodegroup-deleted --cluster-name "$STACK" --nodegroup-name "$STACK-ng"
for addon in coredns kube-proxy vpc-cni eks-pod-identity-agent; do
 aws eks delete-addon --cluster-name "$STACK" --addon-name "$addon"
 aws eks wait addon-deleted --cluster-name "$STACK" --addon-name "$addon"
done
# AWS lifecycle removes generated node/cluster access entries with those resources.
aws eks delete-cluster --name "$STACK"
aws eks wait cluster-deleted --name "$STACK"
put cluster-deleted yes
# A private endpoint rule can leave a foreign SG reference; revoke only our recorded rule if SG remains.
SG=$(get cluster-sg)
if aws ec2 describe-security-groups --group-ids "$SG" >/dev/null 2>&1; then
 RULE=$(get private-runner-rule); if [[ -n "$RULE" ]]; then aws ec2 revoke-security-group-ingress --group-id "$SG" --security-group-rule-ids "$RULE"; fi
fi
# Endpoints before subnets; collect IDs from local owned state only.
mapfile -t EPS < <(jq -r 'to_entries[] | select(.key|startswith("vpce-")) | .value' "$STATE")
if (( ${#EPS[@]} )); then
 aws ec2 delete-vpc-endpoints --vpc-endpoint-ids "${EPS[@]}" > "$STATE_DIR/delete-endpoints.json"
 jq -e '.Unsuccessful|length==0' "$STATE_DIR/delete-endpoints.json" >/dev/null
fi
for az in a b; do aws ec2 delete-nat-gateway --nat-gateway-id "$(get "nat-$az")"; done
for az in a b; do aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$(get "nat-$az")"; aws ec2 release-address --allocation-id "$(get "eip-$az")"; done
# Wait explicitly for managed endpoint/NAT/cluster ENIs to disappear. Never delete unknown ENIs.
aws ec2 describe-network-interfaces --filters Name=vpc-id,Values="$(get vpc)" > "$STATE_DIR/enis-before-vpc-delete.json"
if [[ "$(jq '.NetworkInterfaces|length' "$STATE_DIR/enis-before-vpc-delete.json")" != 0 ]]; then echo 'ENIs remain: wait/review their owners; use stage92 when none remain. No forced deletion.' >&2; exit 1; fi
put infra-services-deleted yes
echo 'Continue 92-cleanup-network-iam.sh after ENI review. This script is staged, NOT safe for arbitrary full rerun after partial deletion; consult README recovery.'
