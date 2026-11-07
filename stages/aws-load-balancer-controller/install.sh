#!/usr/bin/env bash
# Install the AWS Load Balancer Controller with Helm.
# This is not an AWS CLI-only step. The chart is the install path documented by Amazon EKS.
# IAM for the Terraform path is created by Terraform. IAM for the AWS CLI path is created by cli/bin/20-iam.sh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROVISIONER="${1:-}"
[[ "${PROVISIONER}" == "terraform" || "${PROVISIONER}" == "awscli" ]] || {
  echo "Usage: $0 terraform|awscli" >&2
  exit 1
}

command -v helm >/dev/null
command -v kubectl >/dev/null
command -v aws >/dev/null
command -v jq >/dev/null

if [[ "${PROVISIONER}" == "awscli" ]]; then
  # shellcheck source=../../cli/lib/common.sh
  source "${REPO_ROOT}/cli/lib/common.sh"
  load_config
  assert_owned_cluster "${CLUSTER_NAME}"
  require_context
  VPC_ID="$(state_get VPC_ID)"
  ROLE_ARN="$(state_get LBC_ROLE_ARN)"
else
  command -v terraform >/dev/null
  CLUSTER_NAME="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw cluster_name)"
  AWS_REGION="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw region)"
  [[ "${CLUSTER_NAME}" == awseks-tf-* ]] || {
    echo "Terraform output cluster_name must use the awseks-tf- prefix." >&2
    exit 1
  }
  VPC_ID="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw vpc_id)"
  ROLE_ARN="$(terraform -chdir="${REPO_ROOT}/terraform" output -raw load_balancer_controller_role_arn)"
  KUBECONFIG_PATH="${REPO_ROOT}/terraform/kubeconfig-${CLUSTER_NAME}"
  export AWS_REGION AWS_DEFAULT_REGION="${AWS_REGION}" KUBECONFIG="${KUBECONFIG_PATH}"
  aws eks update-kubeconfig --region "${AWS_REGION}" --name "${CLUSTER_NAME}" --kubeconfig "${KUBECONFIG_PATH}" --alias "${CLUSTER_NAME}"
  current="$(kubectl config current-context)"
  [[ "${current}" == "${CLUSTER_NAME}" ]] || {
    echo "Refusing to install into context ${current}." >&2
    exit 1
  }
fi

existing="$(aws eks list-pod-identity-associations --region "${AWS_REGION}" --cluster-name "${CLUSTER_NAME}" --namespace kube-system --service-account aws-load-balancer-controller --query 'associations[0].associationId' --output text)"
if [[ -z "${existing}" || "${existing}" == "None" ]]; then
  if [[ "${PROVISIONER}" == "terraform" ]]; then
    echo "The Pod Identity association is missing. Re-run terraform apply. This script does not create Terraform-owned IAM." >&2
    exit 1
  fi
  aws eks create-pod-identity-association \
    --region "${AWS_REGION}" \
    --cluster-name "${CLUSTER_NAME}" \
    --namespace kube-system \
    --service-account aws-load-balancer-controller \
    --role-arn "${ROLE_ARN}"
else
  echo "Pod Identity association ${existing} already exists."
fi

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
# Upstream release v3.6.2 and chart 3.6.2 (appVersion v3.6.2) were fetched on 2026-11-07.
# The Amazon EKS user-guide install page still shows controller v2.14.1 and chart 1.14.0.
# Those two bytes of IAM policy match. This stage follows the current upstream chart and
# refuses to float if 3.6.2 is not in the chart repository.
if ! helm search repo eks/aws-load-balancer-controller --version 3.6.2 | grep -q '3.6.2'; then
  echo "Helm chart eks/aws-load-balancer-controller version 3.6.2 was not found. Refusing to install a different chart. The EKS user guide still documents chart 1.14.0; do not treat that page as the upstream release." >&2
  exit 1
fi

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --version 3.6.2 \
  --set clusterName="${CLUSTER_NAME}" \
  --set region="${AWS_REGION}" \
  --set vpcId="${VPC_ID}" \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --wait \
  --timeout 10m

kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=180s
echo "Controller installed with Helm chart 3.6.2. region and vpcId are set because node IMDS hop limit is 1."
echo "Expected: deployment aws-load-balancer-controller shows READY 2/2."
