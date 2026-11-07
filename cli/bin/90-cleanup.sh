#!/usr/bin/env bash
# Delete only the resources recorded by this CLI path, in an order that releases load balancers and volumes first.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd jq

[[ -f "${STATE_FILE}" ]] || die "No ${STATE_FILE}. Refusing to guess which resources to delete."
[[ "$(state_get PROVISIONER || true)" == "awscli" ]] || die "State file provisioner is not awscli."
[[ "$(state_get CLUSTER_NAME || true)" == "${CLUSTER_NAME}" ]] || die "State file cluster does not match CLUSTER_NAME."

cat <<EOF
This deletes the AWS CLI lab cluster ${CLUSTER_NAME} in ${AWS_REGION} and the resource ids recorded in
${STATE_FILE}. It does not scan the account for similarly named resources.

Data on PersistentVolumes in this cluster will be deleted when their reclaim policy is Delete.
Load balancers and NAT gateways stop billing only after they are gone. Confirm the bill the next day.

Type the confirmation exactly. There is no --yes flag.
EOF
confirm_phrase "delete ${CLUSTER_NAME}"

delete_k8s_load_balancers() {
  [[ -f "${KUBECONFIG_PATH}" ]] || {
    info "No lab kubeconfig. Skipping kubectl deletes. Load balancers may still exist; the tag wait below still runs."
    return 0
  }
  export KUBECONFIG="${KUBECONFIG_PATH}"
  local current
  current="$(kubectl config current-context 2>/dev/null || true)"
  [[ "${current}" == "${CLUSTER_NAME}" ]] || die "Kubeconfig context is '${current}', not ${CLUSTER_NAME}. Refusing to delete Kubernetes objects."
  info "Deleting Ingress objects, LoadBalancer services, and PVCs before the controller and nodes go away."
  kubectl delete ingress --all -A --wait=true --timeout=300s || info "No ingress objects deleted."
  while read -r ns name; do
    [[ -n "${ns}" ]] || continue
    kubectl delete service -n "${ns}" "${name}" --wait=true --timeout=180s || true
  done < <(kubectl get svc -A -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"')
  kubectl delete pvc --all -A --wait=true --timeout=300s || info "No PVCs deleted."
  if helm status aws-load-balancer-controller -n kube-system >/dev/null 2>&1; then
    helm uninstall aws-load-balancer-controller -n kube-system
  fi
  info "Waiting for load balancers tagged for this cluster to disappear."
  for _ in $(seq 1 30); do
    count="$(aws_cli resourcegroupstaggingapi get-resources \
      --resource-type-filters elasticloadbalancing:loadbalancer \
      --tag-filters "Key=elbv2.k8s.aws/cluster,Values=${CLUSTER_NAME}" \
      --query 'length(ResourceTagMappingList)' --output text)"
    [[ "${count}" == "0" ]] && break
    info "Still ${count} load balancer(s) tagged elbv2.k8s.aws/cluster=${CLUSTER_NAME}."
    sleep 20
  done
}

delete_addon() {
  local addon="$1"
  if aws_cli eks describe-addon --cluster-name "${CLUSTER_NAME}" --addon-name "${addon}" >/dev/null 2>&1; then
    aws_cli eks delete-addon --cluster-name "${CLUSTER_NAME}" --addon-name "${addon}"
    wait_addon_deleted "${addon}"
  fi
}

delete_role() {
  local role_name="$1"
  local provisioner attached policy
  if ! aws_cli iam get-role --role-name "${role_name}" >/dev/null 2>&1; then
    return 0
  fi
  provisioner="$(aws_cli iam list-role-tags --role-name "${role_name}" --query "Tags[?Key=='Provisioner'].Value | [0]" --output text)"
  [[ "${provisioner}" == "awscli" ]] || die "Role ${role_name} is not tagged Provisioner=awscli."
  attached="$(aws_cli iam list-attached-role-policies --role-name "${role_name}" --query 'AttachedPolicies[].PolicyArn' --output text)"
  read -r -a policies <<<"${attached}"
  for policy in "${policies[@]}"; do
    [[ -n "${policy}" && "${policy}" != "None" ]] || continue
    aws_cli iam detach-role-policy --role-name "${role_name}" --policy-arn "${policy}"
  done
  aws_cli iam delete-role --role-name "${role_name}"
}

if [[ "$(state_get CLUSTER_CREATED || true)" == "true" ]]; then
  assert_owned_cluster "${CLUSTER_NAME}"
  delete_k8s_load_balancers
  delete_addon aws-ebs-csi-driver
  delete_addon coredns
  delete_addon kube-proxy
  delete_addon vpc-cni
  delete_addon eks-pod-identity-agent
  if [[ -n "$(state_get NODEGROUP_NAME || true)" ]]; then
    nodegroup="$(state_get NODEGROUP_NAME)"
    if aws_cli eks describe-nodegroup --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${nodegroup}" >/dev/null 2>&1; then
      aws_cli eks delete-nodegroup --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${nodegroup}"
      aws_cli eks wait nodegroup-deleted --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${nodegroup}"
    fi
  fi
  aws_cli eks update-cluster-config --name "${CLUSTER_NAME}" --no-deletion-protection || info "Deletion protection was already off or the update was rejected. The delete call below will report the real error if the cluster is still protected."
  aws_cli eks wait cluster-active --name "${CLUSTER_NAME}" || true
  aws_cli eks delete-cluster --name "${CLUSTER_NAME}"
  aws_cli eks wait cluster-deleted --name "${CLUSTER_NAME}"
  checkpoint "cluster-deleted"
fi

if [[ -n "$(state_get LAUNCH_TEMPLATE_ID || true)" ]]; then
  aws_cli ec2 delete-launch-template --launch-template-id "$(state_get LAUNCH_TEMPLATE_ID)" || info "Launch template was already gone."
fi

delete_role "${CLUSTER_NAME}-aws-load-balancer-controller"
delete_role "${CLUSTER_NAME}-ebs-csi"
delete_role "${CLUSTER_NAME}-node"
delete_role "${CLUSTER_NAME}-cluster"
if [[ -n "$(state_get LBC_POLICY_ARN || true)" ]]; then
  versions="$(aws_cli iam list-policy-versions --policy-arn "$(state_get LBC_POLICY_ARN)" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text || true)"
  for version in ${versions}; do
    [[ -n "${version}" && "${version}" != "None" ]] || continue
    aws_cli iam delete-policy-version --policy-arn "$(state_get LBC_POLICY_ARN)" --version-id "${version}"
  done
  aws_cli iam delete-policy --policy-arn "$(state_get LBC_POLICY_ARN)" || info "Controller policy was already gone."
fi

if [[ -n "$(state_get INTERFACE_ENDPOINT_IDS || true)" ]]; then
  IFS=',' read -r -a endpoint_ids <<<"$(state_get INTERFACE_ENDPOINT_IDS)"
  aws_cli ec2 delete-vpc-endpoints --vpc-endpoint-ids "${endpoint_ids[@]}"
fi
if [[ -n "$(state_get S3_ENDPOINT_ID || true)" ]]; then
  aws_cli ec2 delete-vpc-endpoints --vpc-endpoint-ids "$(state_get S3_ENDPOINT_ID)"
fi

if [[ -n "$(state_get NAT_GATEWAY_IDS || true)" ]]; then
  IFS=',' read -r -a nat_ids <<<"$(state_get NAT_GATEWAY_IDS)"
  for nat_id in "${nat_ids[@]}"; do
    aws_cli ec2 delete-nat-gateway --nat-gateway-id "${nat_id}" >/dev/null || true
  done
  for nat_id in "${nat_ids[@]}"; do
    for _ in $(seq 1 60); do
      nat_state="$(aws_cli ec2 describe-nat-gateways --nat-gateway-ids "${nat_id}" --query 'NatGateways[0].State' --output text)"
      [[ "${nat_state}" == "deleted" ]] && break
      sleep 10
    done
  done
fi
if [[ -n "$(state_get EIP_ALLOCATION_IDS || true)" ]]; then
  IFS=',' read -r -a eip_ids <<<"$(state_get EIP_ALLOCATION_IDS)"
  for allocation_id in "${eip_ids[@]}"; do
    aws_cli ec2 release-address --allocation-id "${allocation_id}" || info "Address ${allocation_id} was not released. It may still be attached."
  done
fi

if [[ -n "$(state_get VPC_ID || true)" ]]; then
  vpc_id="$(state_get VPC_ID)"
  assert_owned_vpc "${vpc_id}"
  associations="$(aws_cli ec2 describe-route-tables --filters "Name=vpc-id,Values=${vpc_id}" --query 'RouteTables[].Associations[?Main==`false`].RouteTableAssociationId' --output text)"
  for association in ${associations}; do
    [[ -n "${association}" && "${association}" != "None" ]] || continue
    aws_cli ec2 disassociate-route-table --association-id "${association}" || true
  done
  tables="$(aws_cli ec2 describe-route-tables --filters "Name=vpc-id,Values=${vpc_id}" "Name=tag:Provisioner,Values=awscli" --query 'RouteTables[].RouteTableId' --output text)"
  for table in ${tables}; do
    [[ -n "${table}" && "${table}" != "None" ]] || continue
    aws_cli ec2 delete-route-table --route-table-id "${table}" || info "Route table ${table} was not deleted."
  done
  if [[ -n "$(state_get IGW_ID || true)" ]]; then
    aws_cli ec2 detach-internet-gateway --internet-gateway-id "$(state_get IGW_ID)" --vpc-id "${vpc_id}" || true
    aws_cli ec2 delete-internet-gateway --internet-gateway-id "$(state_get IGW_ID)" || true
  fi
  subnets="$(aws_cli ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" "Name=tag:Provisioner,Values=awscli" --query 'Subnets[].SubnetId' --output text)"
  for subnet in ${subnets}; do
    [[ -n "${subnet}" && "${subnet}" != "None" ]] || continue
    aws_cli ec2 delete-subnet --subnet-id "${subnet}"
  done
  for sg in "$(state_get API_SG_ID || true)" "$(state_get ENDPOINT_SG_ID || true)"; do
    [[ -n "${sg}" ]] || continue
    aws_cli ec2 delete-security-group --group-id "${sg}" || info "Security group ${sg} was not deleted."
  done
  info "Remaining ENIs in ${vpc_id}. In-use ENIs from a deleted cluster usually disappear within a few minutes. This script does not detach ENIs it did not create."
  aws_cli ec2 describe-network-interfaces --filters "Name=vpc-id,Values=${vpc_id}" \
    --query 'NetworkInterfaces[].{Id:NetworkInterfaceId,Status:Status,Description:Description}' --output json || true
  aws_cli ec2 delete-vpc --vpc-id "${vpc_id}"
fi

log_group="/aws/eks/${CLUSTER_NAME}/cluster"
if aws_cli logs describe-log-groups --log-group-name-prefix "${log_group}" --query "logGroups[?logGroupName=='${log_group}'].logGroupName" --output text | grep -qx "${log_group}"; then
  aws_cli logs delete-log-group --log-group-name "${log_group}" || true
fi

checkpoint "cleanup-finished"
cat <<EOF
Cleanup commands finished for ${CLUSTER_NAME}.
Check Cost Explorer or the billing console for NAT gateways, Elastic IPs, load balancers, and EBS volumes
that still mention this cluster. This script does not claim the account bill is zero.
EOF
