#!/usr/bin/env bash
# Optional community EKS add-on. AWS documents the lifecycle API, not the metrics-server software itself.
# The version is the default compatible version from describe-addon-versions at install time.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROVISIONER="${1:-}"
[[ "${PROVISIONER}" == "awscli" || "${PROVISIONER}" == "terraform" ]] || {
  echo "Usage: $0 awscli|terraform" >&2
  exit 1
}

if [[ "${PROVISIONER}" == "awscli" ]]; then
  # shellcheck source=../../cli/lib/common.sh
  source "${REPO_ROOT}/cli/lib/common.sh"
  load_config
  assert_owned_cluster "${CLUSTER_NAME}"
  require_context
else
  CLUSTER_NAME="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw cluster_name)"
  AWS_REGION="$(awk -F= '/^[[:space:]]*region[[:space:]]*=/{gsub(/[" ]/,"",$2); print $2; exit}' "${REPO_ROOT}/terraform/terraform.tfvars")"
  KUBERNETES_VERSION="$(awk -F= '/^[[:space:]]*kubernetes_version[[:space:]]*=/{gsub(/[" ]/,"",$2); print $2; exit}' "${REPO_ROOT}/terraform/terraform.tfvars")"
  export AWS_REGION AWS_DEFAULT_REGION="${AWS_REGION}"
  export KUBECONFIG="${REPO_ROOT}/terraform/kubeconfig-${CLUSTER_NAME}"
  [[ "${CLUSTER_NAME}" == awseks-tf-* ]] || exit 1
fi

version="$(aws eks describe-addon-versions --region "${AWS_REGION}" \
  --addon-name metrics-server \
  --kubernetes-version "${KUBERNETES_VERSION}" \
  --query 'addons[0].addonVersions[?compatibilities[?defaultVersion==`true`]].addonVersion | [0]' \
  --output text)"
[[ -n "${version}" && "${version}" != "None" ]] || {
  echo "No default metrics-server add-on for Kubernetes ${KUBERNETES_VERSION}." >&2
  exit 1
}
echo "Installing community add-on metrics-server ${version}. This is the API default, not a pin from a user-guide table."
aws eks create-addon --region "${AWS_REGION}" --cluster-name "${CLUSTER_NAME}" --addon-name metrics-server --addon-version "${version}" --resolve-conflicts OVERWRITE
aws eks wait addon-active --region "${AWS_REGION}" --cluster-name "${CLUSTER_NAME}" --addon-name metrics-server
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
echo "Expected after a short delay: kubectl top nodes shows CPU and memory. Immediately after install the metrics API can return empty."
