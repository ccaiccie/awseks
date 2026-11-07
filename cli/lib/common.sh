#!/usr/bin/env bash
# Shared helpers for the AWS CLI path. Source this file; do not execute it.
# The Terraform path must not source it. Cluster names are guarded below.

if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "ERROR: these scripts require bash." >&2
  exit 1
fi

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${ROOT_DIR}/state"
STATE_FILE="${STATE_DIR}/cluster.env"
CHECKPOINT_FILE="${STATE_DIR}/checkpoints.log"
CONFIG_FILE="${ROOT_DIR}/config.env"
KUBECONFIG_PATH="${STATE_DIR}/kubeconfig"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

info() {
  echo "INFO: $*" >&2
}

checkpoint() {
  mkdir -p "${STATE_DIR}"
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | tee -a "${CHECKPOINT_FILE}"
}

load_config() {
  [[ -f "${CONFIG_FILE}" ]] || die "Missing ${CONFIG_FILE}. Copy cli/config.env.example to cli/config.env and edit it. Do not commit cli/config.env."
  # shellcheck disable=SC1090
  set -a
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
  set +a

  : "${OWNER:=student}"
  : "${KUBERNETES_VERSION:=1.36}"
  : "${VPC_CIDR:=10.0.0.0/16}"
  : "${SERVICE_IPV4_CIDR:=172.20.0.0/16}"
  : "${AZ_COUNT:=2}"
  : "${NAT_STRATEGY:=single}"
  : "${ENABLE_INTERFACE_ENDPOINTS:=false}"
  : "${ENABLE_PUBLIC_ENDPOINT:=false}"
  : "${PUBLIC_ACCESS_CIDRS:=}"
  : "${NODE_INSTANCE_TYPE:=t3.medium}"
  : "${NODE_AMI_TYPE:=AL2023_x86_64_STANDARD}"
  : "${NODE_CAPACITY_TYPE:=ON_DEMAND}"
  : "${NODE_MIN:=2}"
  : "${NODE_DESIRED:=2}"
  : "${NODE_MAX:=3}"
  : "${NODE_DISK_GIB:=20}"
  : "${DELETION_PROTECTION:=true}"
  : "${BOOTSTRAP_CLUSTER_CREATOR_ADMIN:=true}"

  [[ -n "${AWS_REGION:-}" ]] || die "AWS_REGION is empty in ${CONFIG_FILE}."
  [[ -n "${CLUSTER_NAME:-}" ]] || die "CLUSTER_NAME is empty in ${CONFIG_FILE}."
  [[ "${CLUSTER_NAME}" =~ ^awseks-cli-[a-z0-9-]{1,24}$ ]] || die "CLUSTER_NAME must match ^awseks-cli-[a-z0-9-]{1,24}$. The Terraform path uses the awseks-tf- prefix."
  [[ "${KUBERNETES_VERSION}" =~ ^1\.[0-9]+$ ]] || die "KUBERNETES_VERSION must look like 1.36. Standard support is checked with aws eks describe-cluster-versions, not a fixed list."
  [[ "${AZ_COUNT}" =~ ^[23]$ ]] || die "AZ_COUNT must be 2 or 3."
  [[ "${NAT_STRATEGY}" =~ ^(single|per_az|none)$ ]] || die "NAT_STRATEGY must be single, per_az, or none."
  [[ "${ENABLE_PUBLIC_ENDPOINT}" =~ ^(true|false)$ ]] || die "ENABLE_PUBLIC_ENDPOINT must be true or false."
  [[ "${ENABLE_INTERFACE_ENDPOINTS}" =~ ^(true|false)$ ]] || die "ENABLE_INTERFACE_ENDPOINTS must be true or false."
  [[ "${NODE_CAPACITY_TYPE}" =~ ^(ON_DEMAND|SPOT)$ ]] || die "NODE_CAPACITY_TYPE must be ON_DEMAND or SPOT."
  [[ "${NODE_AMI_TYPE}" =~ ^(AL2023_x86_64_STANDARD|AL2023_ARM_64_STANDARD)$ ]] || die "NODE_AMI_TYPE must be an AL2023 managed-node AMI type."
  [[ "${DELETION_PROTECTION}" =~ ^(true|false)$ ]] || die "DELETION_PROTECTION must be true or false."
  [[ "${NODE_MIN}" -ge 1 && "${NODE_MIN}" -le "${NODE_DESIRED}" && "${NODE_DESIRED}" -le "${NODE_MAX}" && "${NODE_MAX}" -le 6 ]] || die "Require 1 <= NODE_MIN <= NODE_DESIRED <= NODE_MAX <= 6."

  if [[ "${ENABLE_PUBLIC_ENDPOINT}" == "true" ]]; then
    [[ -n "${PUBLIC_ACCESS_CIDRS}" ]] || die "ENABLE_PUBLIC_ENDPOINT=true requires PUBLIC_ACCESS_CIDRS, for example your /32. 0.0.0.0/0 is rejected."
    [[ "${PUBLIC_ACCESS_CIDRS}" != *"0.0.0.0/0"* ]] || die "PUBLIC_ACCESS_CIDRS must not contain 0.0.0.0/0."
    [[ "${PUBLIC_ACCESS_CIDRS}" != *"192.0.2."* && "${PUBLIC_ACCESS_CIDRS}" != *"198.51.100."* && "${PUBLIC_ACCESS_CIDRS}" != *"203.0.113."* ]] || die "Replace the documentation CIDR in PUBLIC_ACCESS_CIDRS with your client CIDR."
  fi

  if [[ "${NAT_STRATEGY}" == "none" ]]; then
    ENABLE_INTERFACE_ENDPOINTS="true"
  fi

  export AWS_REGION
  export AWS_DEFAULT_REGION="${AWS_REGION}"
  export KUBECONFIG="${KUBECONFIG_PATH}"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

aws_cli() {
  command aws --region "${AWS_REGION}" "$@"
}

state_get() {
  local key="$1"
  local line
  [[ -f "${STATE_FILE}" ]] || return 1
  line="$(grep -E "^${key}=" "${STATE_FILE}" | tail -n 1 || true)"
  [[ -n "${line}" ]] || return 1
  printf '%s' "${line#*=}"
}

state_set() {
  local key="$1"
  local value="$2"
  local tmp
  mkdir -p "${STATE_DIR}"
  touch "${STATE_FILE}"
  tmp="$(mktemp)"
  grep -Ev "^${key}=" "${STATE_FILE}" >"${tmp}" || true
  printf '%s=%s\n' "${key}" "${value}" >>"${tmp}"
  mv "${tmp}" "${STATE_FILE}"
  chmod 600 "${STATE_FILE}"
}

confirm_phrase() {
  local expected="$1"
  local reply
  echo "Type exactly: ${expected}"
  read -r reply
  [[ "${reply}" == "${expected}" ]] || die "Confirmation did not match. Nothing was changed."
}

refuse_credential_print() {
  if [[ -n "${AWS_ACCESS_KEY_ID:-}" || -n "${AWS_SECRET_ACCESS_KEY:-}" || -n "${AWS_SESSION_TOKEN:-}" ]]; then
    info "Static or session credentials are present in the environment. This lab will not print or store them. Prefer an AWS CLI profile or IAM Identity Center."
  fi
}

caller_identity() {
  aws_cli sts get-caller-identity --output json
}

tag_resource() {
  local resource_id="$1"
  local name="$2"
  aws_cli ec2 create-tags --resources "${resource_id}" --tags \
    "Key=Name,Value=${name}" \
    Key=Project,Value=awseks-practice \
    Key=Provisioner,Value=awscli \
    "Key=Owner,Value=${OWNER}" \
    "Key=Cluster,Value=${CLUSTER_NAME}"
}

subnet_cidr() {
  local index="$1"
  python3 - "${VPC_CIDR}" "${index}" <<'PY'
import ipaddress
import sys
network = ipaddress.ip_network(sys.argv[1])
index = int(sys.argv[2])
print(list(network.subnets(new_prefix=network.prefixlen + 8))[index])
PY
}

assert_owned_cluster() {
  local name="$1"
  local project provisioner
  project="$(aws_cli eks describe-cluster --name "${name}" --query "cluster.tags.Project" --output text)"
  provisioner="$(aws_cli eks describe-cluster --name "${name}" --query "cluster.tags.Provisioner" --output text)"
  [[ "${project}" == "awseks-practice" && "${provisioner}" == "awscli" ]] || die "Cluster ${name} is not tagged Project=awseks-practice and Provisioner=awscli. Refusing to touch it."
}

assert_owned_vpc() {
  local vpc_id="$1"
  local project provisioner
  project="$(aws_cli ec2 describe-vpcs --vpc-ids "${vpc_id}" --query 'Vpcs[0].Tags[?Key==`Project`].Value | [0]' --output text)"
  provisioner="$(aws_cli ec2 describe-vpcs --vpc-ids "${vpc_id}" --query 'Vpcs[0].Tags[?Key==`Provisioner`].Value | [0]' --output text)"
  [[ "${project}" == "awseks-practice" && "${provisioner}" == "awscli" ]] || die "VPC ${vpc_id} is not owned by the AWS CLI path."
}

require_context() {
  local current server endpoint
  [[ -f "${KUBECONFIG_PATH}" ]] || die "Missing ${KUBECONFIG_PATH}. Run cli/bin/70-kubeconfig.sh first."
  export KUBECONFIG="${KUBECONFIG_PATH}"
  current="$(kubectl config current-context)"
  [[ "${current}" == "${CLUSTER_NAME}" ]] || die "Current context is '${current}', expected '${CLUSTER_NAME}'. Refusing to send kubectl at another cluster."
  endpoint="$(aws_cli eks describe-cluster --name "${CLUSTER_NAME}" --query 'cluster.endpoint' --output text)"
  server="$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')"
  [[ "${server}" == "${endpoint}" ]] || die "kubeconfig server ${server} does not match the AWS endpoint ${endpoint}."
}

resolve_addon_version() {
  local addon_name="$1"
  local pinned="${2:-}"
  local listed default
  listed="$(aws_cli eks describe-addon-versions \
    --addon-name "${addon_name}" \
    --kubernetes-version "${KUBERNETES_VERSION}" \
    --query 'addons[0].addonVersions[].addonVersion' \
    --output text)"
  default="$(aws_cli eks describe-addon-versions \
    --addon-name "${addon_name}" \
    --kubernetes-version "${KUBERNETES_VERSION}" \
    --query 'addons[0].addonVersions[?compatibilities[?defaultVersion==`true`]].addonVersion | [0]' \
    --output text)"
  [[ -n "${default}" && "${default}" != "None" ]] || die "describe-addon-versions returned no default version for ${addon_name} on Kubernetes ${KUBERNETES_VERSION}."
  if [[ -n "${pinned}" ]]; then
    if [[ " ${listed} " != *" ${pinned} "* ]]; then
      die "Pinned ${addon_name} version ${pinned} is not in describe-addon-versions for Kubernetes ${KUBERNETES_VERSION}. The current default is ${default}. Update docs/versions.md and the pin together. This script will not substitute a version quietly."
    fi
    printf '%s' "${pinned}"
    return 0
  fi
  printf '%s' "${default}"
}

documented_addon_pin() {
  local addon_name="$1"
  case "${KUBERNETES_VERSION}:${addon_name}" in
    1.34:vpc-cni) printf '%s' "v1.23.2-eksbuild.8" ;;
    1.35:vpc-cni) printf '%s' "v1.23.2-eksbuild.8" ;;
    1.36:vpc-cni) printf '%s' "v1.23.2-eksbuild.8" ;;
    1.37:vpc-cni) printf '%s' "v1.23.2-eksbuild.8" ;;
    1.34:kube-proxy) printf '%s' "v1.34.6-eksbuild.62" ;;
    1.35:kube-proxy) printf '%s' "v1.35.3-eksbuild.62" ;;
    1.36:kube-proxy) printf '%s' "v1.36.0-eksbuild.58" ;;
    1.37:kube-proxy) printf '%s' "v1.37.0-eksbuild.32" ;;
    1.34:coredns) printf '%s' "v1.13.2-eksbuild.62" ;;
    1.35:coredns) printf '%s' "v1.14.7-eksbuild.22" ;;
    1.36:coredns) printf '%s' "v1.14.7-eksbuild.22" ;;
    1.37:coredns) printf '%s' "v1.14.7-eksbuild.22" ;;
    *)
      return 0
      ;;
  esac
}

wait_cluster_active() {
  info "Waiting until EKS reports cluster ${CLUSTER_NAME} ACTIVE."
  aws_cli eks wait cluster-active --name "${CLUSTER_NAME}"
}

wait_nodegroup_active() {
  local nodegroup="$1"
  info "Waiting until managed node group ${nodegroup} is ACTIVE."
  aws_cli eks wait nodegroup-active --cluster-name "${CLUSTER_NAME}" --nodegroup-name "${nodegroup}"
}

wait_addon_active() {
  local addon="$1"
  info "Waiting until add-on ${addon} is ACTIVE."
  aws_cli eks wait addon-active --cluster-name "${CLUSTER_NAME}" --addon-name "${addon}"
}

wait_addon_deleted() {
  local addon="$1"
  info "Waiting until add-on ${addon} is deleted."
  aws_cli eks wait addon-deleted --cluster-name "${CLUSTER_NAME}" --addon-name "${addon}"
}
