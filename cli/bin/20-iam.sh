#!/usr/bin/env bash
# Create the cluster role, node role, EBS CSI Pod Identity role, and the
# Load Balancer Controller role. No instance profile: EKS managed node groups create one.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd jq
account="$(state_get ACCOUNT_ID)"
repo_root="$(cd "${ROOT_DIR}/.." && pwd)"
mkdir -p "${STATE_DIR}"

write_service_trust() {
  local principal="$1"
  local path="$2"
  jq -n --arg principal "${principal}" '{
    Version: "2012-10-17",
    Statement: [{
      Sid: "AllowServiceToAssumeRole",
      Effect: "Allow",
      Principal: {Service: $principal},
      Action: "sts:AssumeRole"
    }]
  }' >"${path}"
}

write_pod_trust() {
  local service_account="$1"
  local path="$2"
  jq -n --arg sa "${service_account}" '{
    Version: "2012-10-17",
    Statement: [{
      Sid: "AllowEksAuthToAssumeRoleForPodIdentity",
      Effect: "Allow",
      Principal: {Service: "pods.eks.amazonaws.com"},
      Action: ["sts:AssumeRole", "sts:TagSession"],
      Condition: {StringEquals: {
        "aws:RequestTag/kubernetes-namespace": "kube-system",
        "aws:RequestTag/kubernetes-service-account": $sa
      }}
    }]
  }' >"${path}"
}

ensure_role() {
  local role_name="$1"
  local trust_file="$2"
  local description="$3"
  local arn
  if arn="$(aws_cli iam get-role --role-name "${role_name}" --query 'Role.Arn' --output text 2>/dev/null)"; then
    local provisioner
    provisioner="$(aws_cli iam list-role-tags --role-name "${role_name}" --query "Tags[?Key=='Provisioner'].Value | [0]" --output text)"
    [[ "${provisioner}" == "awscli" ]] || die "IAM role ${role_name} already exists and is not tagged Provisioner=awscli."
    info "Reusing IAM role ${arn}"
    printf '%s' "${arn}"
    return 0
  fi
  arn="$(aws_cli iam create-role \
    --role-name "${role_name}" \
    --assume-role-policy-document "file://${trust_file}" \
    --description "${description}" \
    --tags Key=Project,Value=awseks-practice Key=Provisioner,Value=awscli "Key=Cluster,Value=${CLUSTER_NAME}" "Key=Owner,Value=${OWNER}" \
    --query 'Role.Arn' --output text)"
  printf '%s' "${arn}"
}

attach_managed() {
  local role_name="$1"
  local policy_arn="$2"
  local attached
  attached="$(aws_cli iam list-attached-role-policies --role-name "${role_name}" --query "AttachedPolicies[?PolicyArn=='${policy_arn}'].PolicyArn" --output text)"
  if [[ "${attached}" == "${policy_arn}" ]]; then
    info "Policy already attached: ${policy_arn}"
    return 0
  fi
  aws_cli iam attach-role-policy --role-name "${role_name}" --policy-arn "${policy_arn}"
}

write_service_trust "eks.amazonaws.com" "${STATE_DIR}/cluster-trust.json"
write_service_trust "ec2.amazonaws.com" "${STATE_DIR}/node-trust.json"
write_pod_trust "ebs-csi-controller-sa" "${STATE_DIR}/ebs-trust.json"
write_pod_trust "aws-load-balancer-controller" "${STATE_DIR}/lbc-trust.json"

cluster_arn="$(ensure_role "${CLUSTER_NAME}-cluster" "${STATE_DIR}/cluster-trust.json" "EKS control plane role for ${CLUSTER_NAME}")"
attach_managed "${CLUSTER_NAME}-cluster" "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
attach_managed "${CLUSTER_NAME}-cluster" "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
state_set CLUSTER_ROLE_ARN "${cluster_arn}"

node_arn="$(ensure_role "${CLUSTER_NAME}-node" "${STATE_DIR}/node-trust.json" "EKS managed node role for ${CLUSTER_NAME}")"
attach_managed "${CLUSTER_NAME}-node" "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
attach_managed "${CLUSTER_NAME}-node" "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
attach_managed "${CLUSTER_NAME}-node" "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
state_set NODE_ROLE_ARN "${node_arn}"

ebs_arn="$(ensure_role "${CLUSTER_NAME}-ebs-csi" "${STATE_DIR}/ebs-trust.json" "Pod Identity role for the EBS CSI controller")"
attach_managed "${CLUSTER_NAME}-ebs-csi" "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
state_set EBS_ROLE_ARN "${ebs_arn}"

lbc_policy_name="${CLUSTER_NAME}-AWSLoadBalancerController"
lbc_policy_arn="arn:aws:iam::${account}:policy/${lbc_policy_name}"
if ! aws_cli iam get-policy --policy-arn "${lbc_policy_arn}" >/dev/null 2>&1; then
  lbc_policy_arn="$(aws_cli iam create-policy \
    --policy-name "${lbc_policy_name}" \
    --description "Vendored AWS Load Balancer Controller v2.14.1 policy for ${CLUSTER_NAME}" \
    --policy-document "file://${repo_root}/policies/aws-load-balancer-controller-v2.14.1.json" \
    --tags Key=Project,Value=awseks-practice Key=Provisioner,Value=awscli "Key=Cluster,Value=${CLUSTER_NAME}" \
    --query 'Policy.Arn' --output text)"
fi
lbc_arn="$(ensure_role "${CLUSTER_NAME}-aws-load-balancer-controller" "${STATE_DIR}/lbc-trust.json" "Pod Identity role for the AWS Load Balancer Controller")"
attach_managed "${CLUSTER_NAME}-aws-load-balancer-controller" "${lbc_policy_arn}"
state_set LBC_ROLE_ARN "${lbc_arn}"
state_set LBC_POLICY_ARN "${lbc_policy_arn}"

checkpoint "iam cluster=${cluster_arn} node=${node_arn}"
info "IAM roles recorded. iam:PassRole is explained in docs/iam.md. This script does not attach an AdministratorAccess policy."
info "Expected next: cli/bin/30-cluster.sh. Wait a few seconds if the next step says the role cannot be assumed yet."
