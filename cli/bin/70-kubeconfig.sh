#!/usr/bin/env bash
# Write a lab-local kubeconfig. This does not edit ~/.kube/config.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd kubectl
assert_owned_cluster "${CLUSTER_NAME}"
mkdir -p "${STATE_DIR}"

aws_cli eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --kubeconfig "${KUBECONFIG_PATH}" \
  --alias "${CLUSTER_NAME}"

require_context
kubectl get --raw='/readyz' >/dev/null
checkpoint "kubeconfig ${KUBECONFIG_PATH}"
info "Kubeconfig written to ${KUBECONFIG_PATH}. Export KUBECONFIG to that path in new shells."
info "Expected: kubectl config current-context prints ${CLUSTER_NAME}, and readyz returns ok."
info "Expected next: cli/bin/80-verify.sh"
