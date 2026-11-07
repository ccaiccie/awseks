#!/usr/bin/env bash
set -euo pipefail
LAB_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
[[ -f "$LAB_ROOT/config.env" ]] || { echo 'Copy config.example.env to config.env and review it.' >&2; exit 1; }
# This is a local operator-authored configuration file, never a downloaded secret.
source "$LAB_ROOT/config.env"
export AWS_DEFAULT_REGION="$AWS_REGION" AWS_PAGER="" AWS_CLI_AUTO_PROMPT=off
: "${EXPECTED_ACCOUNT_ID:?}" "${STACK:?}" "${ADMIN_ROLE_ARN:?}" "${ADMIN_PUBLIC_CIDR:?}" "${K8S_VERSION:?}"
[[ "$STACK" =~ ^eksclass-cli-[a-z0-9-]+$ ]] || { echo 'Use a unique CLI-only stack name.' >&2; exit 1; }
[[ "$EXPECTED_ACCOUNT_ID" =~ ^[0-9]{12}$ ]] || { echo 'Set real sandbox account ID.' >&2; exit 1; }
for cmd in aws jq python3; do command -v "$cmd" >/dev/null || { echo "Missing $cmd" >&2; exit 1; }; done
CLI_VERSION=$(aws --version 2>&1)
[[ "$CLI_VERSION" == aws-cli/2.* ]] || { echo 'AWS CLI v2 required.' >&2; exit 1; }
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[[ "$ACCOUNT" == "$EXPECTED_ACCOUNT_ID" ]] || { echo "WRONG ACCOUNT: $ACCOUNT" >&2; exit 1; }
[[ "$ADMIN_ROLE_ARN" == "arn:aws:iam::$ACCOUNT:role/"* ]] || { echo 'Use an IAM role ARN in this sandbox (commercial AWS partition).' >&2; exit 1; }
python3 - "$ADMIN_PUBLIC_CIDR" <<'PY_CHECK'
import ipaddress,sys
n=ipaddress.ip_network(sys.argv[1],strict=True)
assert n.version==4 and n.prefixlen==32 and n.network_address.is_global, 'Use actual global public egress IPv4 /32, not an example address or 0/0'
PY_CHECK
STATE_DIR="$LAB_ROOT/.state/$STACK"
mkdir -p "$STATE_DIR"; chmod 700 "$STATE_DIR"
STATE="$STATE_DIR/resources.json"
if [[ ! -f "$STATE" ]]; then printf '{}\n' > "$STATE"; chmod 600 "$STATE"; fi
get() { jq -r --arg k "$1" '.[$k] // empty' "$STATE"; }
put() { local tmp; tmp=$(mktemp "$STATE_DIR/state.XXXXXX"); jq --arg k "$1" --arg v "$2" '.[$k]=$v' "$STATE" > "$tmp"; chmod 600 "$tmp"; mv "$tmp" "$STATE"; }
# Use only serial execution. An API timeout after successful creation can orphan a resource;
# inspect exact stack tags before retrying, never create blindly after an unknown response.
ensure() { local key="$1"; shift; local id; id=$(get "$key"); if [[ -z "$id" ]]; then id=$("$@"); [[ -n "$id" && "$id" != None ]] || return 1; put "$key" "$id"; fi; printf '%s\n' "$id"; }
mutating() { [[ "${COST_ACK:-NO}" == I_ACCEPT_BILLABLE_SANDBOX ]] || { echo 'Read COSTS.md and set COST_ACK explicitly.' >&2; exit 1; }; }
ctx() {
 command -v kubectl >/dev/null
 export KUBECONFIG="$STATE_DIR/kubeconfig"
 [[ -f "$KUBECONFIG" ]] || { echo 'Run 03-access.sh first.' >&2; exit 1; }
 [[ "$(kubectl config current-context)" == "$STACK" ]] || { echo 'Wrong kubeconfig context.' >&2; exit 1; }
 local endpoint actual
 endpoint=$(aws eks describe-cluster --name "$STACK" --query cluster.endpoint --output text)
 actual=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
 [[ "$endpoint" == "$actual" ]] || { echo 'Wrong API endpoint.' >&2; exit 1; }
}
owned_vpc() {
 local v; v=$(get vpc); [[ -n "$v" ]] || return 1
 [[ "$(aws ec2 describe-vpcs --vpc-ids "$v" --query 'Vpcs[0].Tags[?Key==`EksClassStack`].Value | [0]' --output text)" == "$STACK" ]] || { echo 'VPC ownership mismatch.' >&2; exit 1; }
}
role() {
 local key="$1" name="$2" trust="$3"; shift 3
 local arn; arn=$(get "$key")
 if [[ -z "$arn" ]]; then
  # Fail rather than adopt an existing role with the same name.
  if aws iam get-role --role-name "$name" >"$STATE_DIR/role-check.json" 2>"$STATE_DIR/role-check.err"; then echo "Role $name already exists: investigate ownership" >&2; exit 1; fi
  arn=$(aws iam create-role --role-name "$name" --assume-role-policy-document "file://$trust" --tags Key=EksClassStack,Value="$STACK" --query Role.Arn --output text)
  put "$key" "$arn"
 fi
 for p in "$@"; do aws iam attach-role-policy --role-name "$name" --policy-arn "$p"; done
 printf '%s\n' "$arn"
}
addon_version() {
 local name="$1" key="addon-$1" v; v=$(get "$key")
 if [[ -z "$v" ]]; then
  aws eks describe-addon-versions --addon-name "$name" --kubernetes-version "$K8S_VERSION" > "$STATE_DIR/$name-candidates.json"
  v=$(jq -r '[.addons[].addonVersions[] | select(any(.compatibilities[]; .defaultVersion == true))][0].addonVersion // empty' "$STATE_DIR/$name-candidates.json")
  [[ -n "$v" ]] || { echo "No default compatible $name build; review candidates." >&2; return 1; }
  put "$key" "$v"
 fi
 printf '%s\n' "$v"
}
image_guard() { [[ "$1" =~ @sha256:[a-f0-9]{64}$ ]] || { echo 'Pin a reviewed image digest in config.env; no unverified latest image.' >&2; exit 1; }; }

