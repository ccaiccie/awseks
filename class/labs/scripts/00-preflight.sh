#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[[ "$NODE_DESIRED" =~ ^[234]$ ]] || { echo 'NODE_DESIRED must be2..4 for this fixed teaching range.' >&2; exit 1; }
aws sts get-caller-identity
aws eks describe-cluster-versions --version-status STANDARD_SUPPORT > "$STATE_DIR/cluster-versions.json"
jq -e --arg v "$K8S_VERSION" '.clusterVersions[] | select(.clusterVersion == $v)' "$STATE_DIR/cluster-versions.json" >/dev/null || { echo 'Selected version not in standard support; review current versions.' >&2; exit 1; }
aws ec2 describe-availability-zones --filters Name=state,Values=available Name=zone-type,Values=availability-zone > "$STATE_DIR/azs.json"
mapfile -t AZS < <(jq -r '.AvailabilityZones | sort_by(.ZoneName) | .[].ZoneName' "$STATE_DIR/azs.json")
(( ${#AZS[@]} >= 2 )) || { echo 'Need two standard AZs.' >&2; exit 1; }
put az-a "${AZS[0]}"; put az-b "${AZS[1]}"
aws ec2 describe-instance-type-offerings --location-type availability-zone --filters Name=instance-type,Values="$INSTANCE_TYPE" Name=location,Values="${AZS[0]}","${AZS[1]}"
echo 'Check output includes BOTH AZs. Capacity/quota is not guaranteed by offerings.'
aws service-quotas list-service-quotas --service-code eks > "$STATE_DIR/eks-quotas.json"
printf 'Account %s; region %s; stack %s; Kubernetes %s\n' "$ACCOUNT" "$AWS_REGION" "$STACK" "$K8S_VERSION"
echo 'No creation occurred. Read COSTS.md and PERMISSIONS.md; obtain sandbox authorization before stage 01.'
