#!/usr/bin/env bash
# Wait for the DaemonSet add-ons and the node group, then install CoreDNS and the EBS CSI driver.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
assert_owned_cluster "${CLUSTER_NAME}"
[[ "$(state_get NODEGROUP_CREATED || true)" == "true" ]] || die "Run cli/bin/40-nodegroup.sh first so vpc-cni and the node group are created together."

nodegroup_name="$(state_get NODEGROUP_NAME)"
wait_addon_active eks-pod-identity-agent
wait_addon_active vpc-cni
wait_addon_active kube-proxy
wait_nodegroup_active "${nodegroup_name}"
checkpoint "nodes-and-networking-active"

if ! aws_cli eks describe-addon --cluster-name "${CLUSTER_NAME}" --addon-name coredns >/dev/null 2>&1; then
  coredns_version="$(resolve_addon_version coredns "$(documented_addon_pin coredns)")"
  info "CoreDNS pin confirmed: ${coredns_version}"
  aws_cli eks create-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --addon-name coredns \
    --addon-version "${coredns_version}" \
    --resolve-conflicts OVERWRITE
  state_set ADDON_coredns_VERSION "${coredns_version}"
fi
wait_addon_active coredns

if ! aws_cli eks describe-addon --cluster-name "${CLUSTER_NAME}" --addon-name aws-ebs-csi-driver >/dev/null 2>&1; then
  ebs_version="$(resolve_addon_version aws-ebs-csi-driver)"
  info "aws-ebs-csi-driver default version from describe-addon-versions: ${ebs_version}"
  aws_cli eks create-addon \
    --cluster-name "${CLUSTER_NAME}" \
    --addon-name aws-ebs-csi-driver \
    --addon-version "${ebs_version}" \
    --resolve-conflicts OVERWRITE \
    --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=$(state_get EBS_ROLE_ARN)"
  state_set ADDON_aws_ebs_csi_driver_VERSION "${ebs_version}"
fi
wait_addon_active aws-ebs-csi-driver
checkpoint "coredns-and-ebs-active"
info "System add-ons are ACTIVE. The AWS Load Balancer Controller is not installed here; it needs Helm. See stages/aws-load-balancer-controller/install.sh."
info "Expected next: cli/bin/60-access.sh"
