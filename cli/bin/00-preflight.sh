#!/usr/bin/env bash
# Read-only checks. This script does not create AWS resources.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
refuse_credential_print

require_cmd aws
require_cmd jq
require_cmd kubectl
require_cmd helm
require_cmd python3

aws_version="$(aws --version 2>&1)"
[[ "${aws_version}" == aws-cli/2.* ]] || die "AWS CLI v2 is required. Found: ${aws_version}"
info "AWS CLI: ${aws_version}"

configured_region="$(aws configure get region || true)"
if [[ -n "${configured_region}" && "${configured_region}" != "${AWS_REGION}" ]]; then
  info "The AWS CLI profile region is ${configured_region}. These scripts pass --region ${AWS_REGION} from cli/config.env and do not follow the profile region."
fi

identity="$(caller_identity)"
account="$(jq -r '.Account' <<<"${identity}")"
arn="$(jq -r '.Arn' <<<"${identity}")"
[[ "${account}" =~ ^[0-9]{12}$ ]] || die "get-caller-identity did not return an account id."
info "Caller account: ${account}"
info "Caller ARN: ${arn}"
state_set ACCOUNT_ID "${account}"
state_set CALLER_ARN "${arn}"
state_set PROVISIONER "awscli"
state_set CLUSTER_NAME "${CLUSTER_NAME}"
state_set AWS_REGION "${AWS_REGION}"

eks_versions="$(aws_cli eks describe-addon-versions --addon-name vpc-cni --kubernetes-version "${KUBERNETES_VERSION}" --query 'addons[0].addonVersions[0].addonVersion' --output text)"
[[ -n "${eks_versions}" && "${eks_versions}" != "None" ]] || die "Could not read vpc-cni add-on versions for Kubernetes ${KUBERNETES_VERSION}. The region may not offer that minor, or eks:DescribeAddonVersions is missing."
info "describe-addon-versions is reachable for vpc-cni on ${KUBERNETES_VERSION}. A listed version is ${eks_versions}."

kubectl_version="$(kubectl version --client=true -o json)"
kubectl_git="$(jq -r '.clientVersion.gitVersion' <<<"${kubectl_version}")"
info "kubectl: ${kubectl_git}"
info "Install a kubectl minor within one of ${KUBERNETES_VERSION}. This preflight does not download kubectl."

helm_version="$(helm version --short)"
[[ "${helm_version}" == v3.* || "${helm_version}" == *"v3."* ]] || die "Helm 3 is required. Found: ${helm_version}"
info "Helm: ${helm_version}"

if command -v terraform >/dev/null 2>&1; then
  info "Terraform is installed: $(terraform version -json | jq -r '.terraform_version'). The AWS CLI path does not run it."
else
  info "Terraform is not on PATH. You need it only for the Terraform path."
fi

azs="$(aws_cli ec2 describe-availability-zones --filters Name=state,Values=available Name=opt-in-status,Values=opt-in-not-required --query 'AvailabilityZones[].ZoneName' --output text)"
# shellcheck disable=SC2206
az_array=(${azs})
[[ "${#az_array[@]}" -ge "${AZ_COUNT}" ]] || die "Region ${AWS_REGION} does not have ${AZ_COUNT} available AZs."
state_set AVAILABILITY_ZONES "${azs}"
info "Availability Zones: ${azs}"

checkpoint "preflight account=${account} region=${AWS_REGION} cluster=${CLUSTER_NAME} kubernetes=${KUBERNETES_VERSION}"
info "Preflight passed. No VPC, IAM role, or cluster was created."
