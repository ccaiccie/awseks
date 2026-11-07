#!/usr/bin/env bash
# Create the networking DaemonSet add-ons and the managed node group, then return.
# Waiting happens in 50-addons.sh. Waiting for the node group before vpc-cni exists
# deadlocks: nodes stay NotReady until aws-node runs, and the add-on stays degraded until a node exists.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd jq
assert_owned_cluster "${CLUSTER_NAME}"
[[ -n "$(state_get CLUSTER_SG_ID || true)" ]] || die "Run cli/bin/30-cluster.sh first."

create_addon_if_missing() {
  local addon="$1"
  local version="$2"
  shift 2
  if aws_cli eks describe-addon --cluster-name "${CLUSTER_NAME}" --addon-name "${addon}" >/dev/null 2>&1; then
    info "Add-on ${addon} already exists."
    return 0
  fi
  aws_cli eks create-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --addon-name "${addon}" \
    --addon-version "${version}" \
    --resolve-conflicts OVERWRITE \
    "$@"
  state_set "ADDON_${addon//-/_}_VERSION" "${version}"
}

pod_version="$(resolve_addon_version eks-pod-identity-agent)"
cni_version="$(resolve_addon_version vpc-cni "$(documented_addon_pin vpc-cni)")"
proxy_version="$(resolve_addon_version kube-proxy "$(documented_addon_pin kube-proxy)")"
info "eks-pod-identity-agent version ${pod_version} is the default from describe-addon-versions."
info "vpc-cni ${cni_version} and kube-proxy ${proxy_version} are the documented pins, confirmed compatible by describe-addon-versions."

create_addon_if_missing eks-pod-identity-agent "${pod_version}"
create_addon_if_missing vpc-cni "${cni_version}" \
  --configuration-values '{"enableNetworkPolicy":"true"}'
create_addon_if_missing kube-proxy "${proxy_version}"
checkpoint "early-addons-requested pod-identity=${pod_version} vpc-cni=${cni_version} kube-proxy=${proxy_version}"

if [[ -n "$(state_get NODEGROUP_CREATED || true)" ]]; then
  info "Node group already recorded. 50-addons.sh performs the waits."
  exit 0
fi

nodegroup_name="${CLUSTER_NAME}-managed"
existing="$(aws_cli eks describe-nodegroup --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${nodegroup_name}" --query 'nodegroup.status' --output text 2>/dev/null || true)"
[[ -z "${existing}" || "${existing}" == "None" ]] || die "Node group ${nodegroup_name} already exists and is not in the state file."

if [[ -z "$(state_get LAUNCH_TEMPLATE_ID || true)" ]]; then
  jq -n --arg cluster "${CLUSTER_NAME}" --argjson disk "${NODE_DISK_GIB}" '{
    MetadataOptions: {
      HttpEndpoint: "enabled",
      HttpTokens: "required",
      HttpPutResponseHopLimit: 1,
      InstanceMetadataTags: "enabled"
    },
    BlockDeviceMappings: [{
      DeviceName: "/dev/xvda",
      Ebs: {VolumeSize: $disk, VolumeType: "gp3", Encrypted: true, DeleteOnTermination: true}
    }],
    TagSpecifications: [
      {ResourceType: "instance", Tags: [
        {Key: "Name", Value: ($cluster + "-node")},
        {Key: "Project", Value: "awseks-practice"},
        {Key: "Provisioner", Value: "awscli"},
        {Key: "Cluster", Value: $cluster}
      ]},
      {ResourceType: "volume", Tags: [
        {Key: "Name", Value: ($cluster + "-node")},
        {Key: "Project", Value: "awseks-practice"},
        {Key: "Provisioner", Value: "awscli"}
      ]}
    ]
  }' >"${STATE_DIR}/launch-template.json"
  lt_id="$(aws_cli ec2 create-launch-template \
    --launch-template-name "${CLUSTER_NAME}-nodes" \
    --version-description "imdsv2-hop1-no-ssh" \
    --launch-template-data "file://${STATE_DIR}/launch-template.json" \
    --tag-specifications "ResourceType=launch-template,Tags=[{Key=Name,Value=${CLUSTER_NAME}-nodes},{Key=Project,Value=awseks-practice},{Key=Provisioner,Value=awscli},{Key=Cluster,Value=${CLUSTER_NAME}}]" \
    --query 'LaunchTemplate.LaunchTemplateId' --output text)"
  state_set LAUNCH_TEMPLATE_ID "${lt_id}"
fi

IFS=',' read -r -a private_ids <<<"$(state_get PRIVATE_SUBNET_IDS)"
subnet_json="$(printf '%s\n' "${private_ids[@]}" | jq -R . | jq -s .)"
node_request="$(jq -n \
  --arg cluster "${CLUSTER_NAME}" \
  --arg name "${nodegroup_name}" \
  --arg role "$(state_get NODE_ROLE_ARN)" \
  --arg ami "${NODE_AMI_TYPE}" \
  --arg capacity "${NODE_CAPACITY_TYPE}" \
  --arg instance "${NODE_INSTANCE_TYPE}" \
  --arg lt "$(state_get LAUNCH_TEMPLATE_ID)" \
  --argjson subnets "${subnet_json}" \
  --argjson min "${NODE_MIN}" \
  --argjson desired "${NODE_DESIRED}" \
  --argjson max "${NODE_MAX}" \
  '{
    clusterName: $cluster,
    nodegroupName: $name,
    nodeRole: $role,
    subnets: $subnets,
    amiType: $ami,
    capacityType: $capacity,
    instanceTypes: [$instance],
    scalingConfig: {minSize: $min, maxSize: $max, desiredSize: $desired},
    updateConfig: {maxUnavailable: 1},
    launchTemplate: {id: $lt, version: "$Latest"},
    labels: {"awseks.practice/nodegroup": "default"},
    tags: {Project: "awseks-practice", Provisioner: "awscli", Cluster: $cluster}
  }')"
printf '%s\n' "${node_request}" >"${STATE_DIR}/create-nodegroup.json"
info "Creating managed node group ${nodegroup_name}. There is no remoteAccess block and no SSH key."
aws_cli eks create-nodegroup --cli-input-json "file://${STATE_DIR}/create-nodegroup.json"
state_set NODEGROUP_NAME "${nodegroup_name}"
state_set NODEGROUP_CREATED "true"
checkpoint "nodegroup-requested ${nodegroup_name}"
info "Node group creation has been requested. Do not wait for it in isolation if the add-ons above were skipped."
info "Expected next: cli/bin/50-addons.sh, which waits for the node group and the early add-ons together."
