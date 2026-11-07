#!/usr/bin/env bash
# Orchestrate the AWS CLI path. Does not install Helm releases and does not run cleanup.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
cat <<EOF
You are about to create a billable AWS environment.
Cluster: ${CLUSTER_NAME}
Region:  ${AWS_REGION}
Shape:   standard EKS ${KUBERNETES_VERSION}, ${NODE_DESIRED} x ${NODE_INSTANCE_TYPE}, NAT strategy ${NAT_STRATEGY}.

Charges start when the control plane, NAT gateway, and nodes exist, and they continue until cleanup.
Read docs/cost.md before continuing. This repository has not priced the current hour for you.
The public API is ${ENABLE_PUBLIC_ENDPOINT}. Private API access is always enabled.
This command does not run terraform apply and does not touch a cluster named awseks-tf-*.

EOF
confirm_phrase "provision ${CLUSTER_NAME}"

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${dir}/00-preflight.sh"
"${dir}/10-network.sh"
"${dir}/20-iam.sh"
"${dir}/30-cluster.sh"
"${dir}/40-nodegroup.sh"
"${dir}/50-addons.sh"
"${dir}/60-access.sh"
"${dir}/70-kubeconfig.sh"
"${dir}/80-verify.sh"
info "AWS CLI path is ready. Helm stages are separate: stages/aws-load-balancer-controller/install.sh"
