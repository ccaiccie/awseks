#!/usr/bin/env bash
# Create the standard managed EKS cluster. Auto Mode compute and block storage stay off.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd jq
vpc_id="$(state_get VPC_ID)"
assert_owned_vpc "${vpc_id}"
role_arn="$(state_get CLUSTER_ROLE_ARN)"
api_sg="$(state_get API_SG_ID)"
IFS=',' read -r -a private_ids <<<"$(state_get PRIVATE_SUBNET_IDS)"

if [[ -n "$(state_get CLUSTER_CREATED || true)" ]]; then
  assert_owned_cluster "${CLUSTER_NAME}"
  info "Cluster ${CLUSTER_NAME} is already recorded."
  wait_cluster_active
  exit 0
fi

status="$(aws_cli eks describe-cluster --name "${CLUSTER_NAME}" --query 'cluster.status' --output text 2>/dev/null || true)"
if [[ -n "${status}" && "${status}" != "None" ]]; then
  die "Cluster ${CLUSTER_NAME} already exists (status ${status}) but CLUSTER_CREATED is not in the state file. Refusing to adopt it."
fi

public_json="false"
cidr_json="[]"
if [[ "${ENABLE_PUBLIC_ENDPOINT}" == "true" ]]; then
  public_json="true"
  cidr_json="$(jq -Rn --arg raw "${PUBLIC_ACCESS_CIDRS}" '$raw | split(",")')"
fi
subnet_json="$(printf '%s\n' "${private_ids[@]}" | jq -R . | jq -s .)"
deletion_json="false"
[[ "${DELETION_PROTECTION}" == "true" ]] && deletion_json="true"
creator_json="false"
[[ "${BOOTSTRAP_CLUSTER_CREATOR_ADMIN}" == "true" ]] && creator_json="true"

request="$(jq -n \
  --arg name "${CLUSTER_NAME}" \
  --arg version "${KUBERNETES_VERSION}" \
  --arg role "${role_arn}" \
  --arg service_cidr "${SERVICE_IPV4_CIDR}" \
  --arg api_sg "${api_sg}" \
  --arg owner "${OWNER}" \
  --argjson subnets "${subnet_json}" \
  --argjson public "${public_json}" \
  --argjson cidrs "${cidr_json}" \
  --argjson deletion "${deletion_json}" \
  --argjson creator "${creator_json}" \
  '{
    name: $name,
    version: $version,
    roleArn: $role,
    resourcesVpcConfig: (
      {
        subnetIds: $subnets,
        securityGroupIds: [$api_sg],
        endpointPrivateAccess: true,
        endpointPublicAccess: $public
      } + (if $public then {publicAccessCidrs: $cidrs} else {} end)
    ),
    kubernetesNetworkConfig: {ipFamily: "ipv4", serviceIpv4Cidr: $service_cidr},
    accessConfig: {authenticationMode: "API", bootstrapClusterCreatorAdminPermissions: $creator},
    upgradePolicy: {supportType: "STANDARD"},
    bootstrapSelfManagedAddons: false,
    deletionProtection: $deletion,
    tags: {Project: "awseks-practice", Provisioner: "awscli", Owner: $owner, Cluster: $name}
  }')"

printf '%s\n' "${request}" >"${STATE_DIR}/create-cluster.json"
info "Creating cluster ${CLUSTER_NAME}. The control plane usually takes 10 to 15 minutes."
info "Authentication mode is API. Self-managed vpc-cni, kube-proxy, and CoreDNS are not installed; 50-addons.sh installs the managed add-ons."

created=false
for attempt in 1 2 3 4 5 6; do
  if aws_cli eks create-cluster --cli-input-json "file://${STATE_DIR}/create-cluster.json"; then
    created=true
    break
  fi
  info "create-cluster attempt ${attempt} failed. IAM can take a short time to accept a new role. Sleeping 20 seconds."
  sleep 20
done
[[ "${created}" == "true" ]] || die "create-cluster failed after retries. Read the error above. A common cause is a missing iam:PassRole on ${role_arn} for eks.amazonaws.com."

state_set CLUSTER_CREATED "true"
wait_cluster_active
assert_owned_cluster "${CLUSTER_NAME}"
endpoint="$(aws_cli eks describe-cluster --name "${CLUSTER_NAME}" --query 'cluster.endpoint' --output text)"
cluster_sg="$(aws_cli eks describe-cluster --name "${CLUSTER_NAME}" --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)"
state_set CLUSTER_ENDPOINT "${endpoint}"
state_set CLUSTER_SG_ID "${cluster_sg}"
checkpoint "cluster-active endpoint=${endpoint} cluster-sg=${cluster_sg}"
info "Cluster is ACTIVE. Private endpoint is enabled. Public endpoint is ${ENABLE_PUBLIC_ENDPOINT}."
info "Expected example: cluster.status is ACTIVE and resourcesVpcConfig.endpointPrivateAccess is true."
info "Expected next: cli/bin/40-nodegroup.sh and cli/bin/50-addons.sh. provision.sh runs node group creation before the add-on wait, in the order those scripts implement."
