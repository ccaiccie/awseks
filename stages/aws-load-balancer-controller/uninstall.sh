#!/usr/bin/env bash
# Remove the Helm release only. IAM and the Pod Identity association stay with the path that created them.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROVISIONER="${1:-}"
[[ "${PROVISIONER}" == "terraform" || "${PROVISIONER}" == "awscli" ]] || {
  echo "Usage: $0 terraform|awscli" >&2
  exit 1
}

if [[ "${PROVISIONER}" == "awscli" ]]; then
  # shellcheck source=../../cli/lib/common.sh
  source "${REPO_ROOT}/cli/lib/common.sh"
  load_config
  require_context
else
  CLUSTER_NAME="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw cluster_name)"
  export KUBECONFIG="${REPO_ROOT}/terraform/kubeconfig-${CLUSTER_NAME}"
  current="$(kubectl config current-context)"
  [[ "${current}" == "${CLUSTER_NAME}" ]] || {
    echo "Refusing to uninstall from context ${current}." >&2
    exit 1
  }
fi

echo "Delete Ingress and LoadBalancer Services before this script, and wait until their AWS load balancers are gone."
echo "Type: uninstall controller ${CLUSTER_NAME}"
read -r reply
[[ "${reply}" == "uninstall controller ${CLUSTER_NAME}" ]] || {
  echo "Confirmation did not match." >&2
  exit 1
}
helm uninstall aws-load-balancer-controller -n kube-system
echo "Helm release removed. For the Terraform path, run the reviewed destroy only after finalizers are gone. For the AWS CLI path, cli/bin/90-cleanup.sh deletes the IAM role."
