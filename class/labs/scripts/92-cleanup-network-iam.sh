#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; owned_vpc
[[ "${DELETE_STACK:-}" == "$STACK" && "$(get cluster-deleted)" == yes ]] || { echo 'Confirm prior cleanup checkpoints.' >&2; exit 1; }
COUNT=$(aws ec2 describe-network-interfaces --filters Name=vpc-id,Values="$(get vpc)" --query 'length(NetworkInterfaces)' --output text)
[[ "$COUNT" == 0 ]] || { echo 'ENIs remain: review exact owner, do not force-delete.' >&2; exit 1; }
# Delete ONLY SGs whose explicit IDs were stored; default SG is removed by VPC deletion.
for key in endpoint-sg cluster-sg; do
 ID=$(get "$key")
 if [[ -n "$ID" ]] && aws ec2 describe-security-groups --group-ids "$ID" >/dev/null 2>&1; then aws ec2 delete-security-group --group-id "$ID"; fi
done
for az in a b; do
 aws ec2 disassociate-route-table --association-id "$(get "assoc-private-$az")"
 aws ec2 disassociate-route-table --association-id "$(get "assoc-public-$az")"
 aws ec2 delete-subnet --subnet-id "$(get "private-$az")"
 aws ec2 delete-subnet --subnet-id "$(get "public-$az")"
 aws ec2 delete-route-table --route-table-id "$(get "private-rt-$az")"
done
aws ec2 delete-route-table --route-table-id "$(get public-rt)"
aws ec2 detach-internet-gateway --vpc-id "$(get vpc)" --internet-gateway-id "$(get igw)"
aws ec2 delete-internet-gateway --internet-gateway-id "$(get igw)"
aws ec2 delete-vpc --vpc-id "$(get vpc)"
aws ec2 delete-launch-template --launch-template-id "$(get launch-template)"
for suffix in cluster node cni lbc ebs reader; do
 NAME="$STACK-$suffix"
 # Resource name and EksClassStack ownership tag must both match.
 if ! aws iam get-role --role-name "$NAME" > "$STATE_DIR/cleanup-role.json" 2> "$STATE_DIR/cleanup-role.err"; then
  echo "Role $NAME not readable/present; inspect error, no mutation attempted." >&2; continue
 fi
 [[ "$(jq -r '.Role.Tags[]? | select(.Key=="EksClassStack") | .Value' "$STATE_DIR/cleanup-role.json")" == "$STACK" ]] || { echo 'IAM ownership mismatch.' >&2; exit 1; }
 mapfile -t POLICIES < <(aws iam list-attached-role-policies --role-name "$NAME" --query 'AttachedPolicies[].PolicyArn' --output text | tr '\t' '\n')
 for p in "${POLICIES[@]}"; do [[ -n "$p" ]] && aws iam detach-role-policy --role-name "$NAME" --policy-arn "$p"; done
 mapfile -t INLINE < <(aws iam list-role-policies --role-name "$NAME" --query 'PolicyNames[]' --output text | tr '\t' '\n')
 for p in "${INLINE[@]}"; do [[ -n "$p" ]] && aws iam delete-role-policy --role-name "$NAME" --policy-name "$p"; done
 aws iam delete-role --role-name "$NAME"
done
POLICY=$(get lbc-policy); if [[ -n "$POLICY" ]]; then aws iam delete-policy --policy-arn "$POLICY"; fi
# Logs intentionally retained unless operator opts into deleting the exact group.
if [[ "${DELETE_LAB_LOGS:-NO}" == YES ]]; then aws logs delete-log-group --log-group-name "/aws/eks/$STACK/cluster"; fi
put cleanup-complete yes
echo 'Review retained logs/snapshots/backups/EFS if optional extensions created them; AWS billing data is delayed. Preserve local evidence/state.'
