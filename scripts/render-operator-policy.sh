#!/usr/bin/env bash
# Print the lab operator policy with placeholders filled in.
# This script does not call AWS and does not create IAM resources.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
account="${ACCOUNT_ID:-}"
region="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
name="${CLUSTER_NAME:-eks-lab}"

if [[ ! "$account" =~ ^[0-9]{12}$ ]]; then
  echo "Set ACCOUNT_ID to the 12 digit account from: aws sts get-caller-identity --query Account --output text" >&2
  exit 1
fi
if [[ ! "$region" =~ ^[a-z]{2}-[a-z]+-[0-9]$ ]]; then
  echo "Set AWS_REGION, for example us-west-2." >&2
  exit 1
fi
if [[ ! "$name" =~ ^[a-z][a-z0-9-]{1,16}$ ]]; then
  echo "CLUSTER_NAME must match the Terraform name variable." >&2
  exit 1
fi

sed \
  -e "s/__ACCOUNT_ID__/${account}/g" \
  -e "s/__REGION__/${region}/g" \
  -e "s/__NAME__/${name}/g" \
  "${root}/terraform/iam/lab-operator-policy.json"
