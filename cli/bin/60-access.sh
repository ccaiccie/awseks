#!/usr/bin/env bash
# Confirm the creator admin access entry and the managed node group's EC2_LINUX entry.
# This script does not grant cluster-admin to the node role.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd jq
assert_owned_cluster "${CLUSTER_NAME}"

entries="$(aws_cli eks list-access-entries --cluster-name "${CLUSTER_NAME}" --output json)"
printf '%s\n' "${entries}" >"${STATE_DIR}/access-entries.json"
info "Access entries:"
jq -r '.accessEntries[]' "${STATE_DIR}/access-entries.json"

node_arn="$(state_get NODE_ROLE_ARN)"
if ! jq -e --arg arn "${node_arn}" '.accessEntries | index($arn)' "${STATE_DIR}/access-entries.json" >/dev/null; then
  info "The managed node group did not publish an access entry for the node role. Creating an EC2_LINUX entry. This type does not receive AmazonEKSClusterAdminPolicy."
  aws_cli eks create-access-entry \
    --cluster-name "${CLUSTER_NAME}" \
    --principal-arn "${node_arn}" \
    --type EC2_LINUX
else
  info "Node role already has an access entry. EKS creates the EC2_LINUX entry for a managed node group when authentication mode is API."
fi

caller="$(state_get CALLER_ARN)"
if ! jq -e --arg arn "${caller}" '.accessEntries | index($arn)' "${STATE_DIR}/access-entries.json" >/dev/null; then
  [[ "${BOOTSTRAP_CLUSTER_CREATOR_ADMIN}" == "true" ]] || die "The caller ${caller} has no access entry and BOOTSTRAP_CLUSTER_CREATOR_ADMIN is false. kubectl will be unauthorized."
  info "Creator access entry is not visible yet. Describing the cluster access config."
fi

aws_cli eks describe-cluster --name "${CLUSTER_NAME}" \
  --query 'cluster.{auth:accessConfig.authenticationMode,creatorAdmin:accessConfig.bootstrapClusterCreatorAdminPermissions,private:resourcesVpcConfig.endpointPrivateAccess,public:resourcesVpcConfig.endpointPublicAccess,cidrs:resourcesVpcConfig.publicAccessCidrs,support:upgradePolicy.supportType}' \
  --output json
checkpoint "access-reviewed"
info "Expected: authenticationMode API, endpointPrivateAccess true, upgradePolicy.supportType STANDARD."
info "Expected next: cli/bin/70-kubeconfig.sh"
