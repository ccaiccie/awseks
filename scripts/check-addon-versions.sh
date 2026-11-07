#!/usr/bin/env bash
# Read-only comparison of pinned addon versions with the EKS API.
# Requires AWS credentials. Does not create or change resources.
set -euo pipefail

region="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
k8s="${KUBERNETES_VERSION:-1.35}"

if [[ -z "$region" ]]; then
  echo "Set AWS_REGION before running this read-only check." >&2
  exit 1
fi

echo "Caller:"
aws sts get-caller-identity --output json
echo
echo "Kubernetes version under test: ${k8s}"
echo "Pins below are from docs/VERSIONS.md. A mismatch means re-pin before apply."
echo

print_latest() {
  local addon="$1"
  local pinned="$2"
  local latest
  latest="$(aws eks describe-addon-versions \
    --region "$region" \
    --addon-name "$addon" \
    --kubernetes-version "$k8s" \
    --query 'addons[0].addonVersions[0].addonVersion' \
    --output text)"
  printf '%-28s pinned=%-24s api_first=%s\n' "$addon" "$pinned" "$latest"
}

print_latest vpc-cni "v1.23.2-eksbuild.8"
case "$k8s" in
  1.34) print_latest coredns "v1.13.2-eksbuild.62"; print_latest kube-proxy "v1.34.6-eksbuild.62" ;;
  1.35) print_latest coredns "v1.14.7-eksbuild.22"; print_latest kube-proxy "v1.35.3-eksbuild.62" ;;
  1.36) print_latest coredns "v1.14.7-eksbuild.22"; print_latest kube-proxy "v1.36.0-eksbuild.58" ;;
  1.37) print_latest coredns "v1.14.7-eksbuild.22"; print_latest kube-proxy "v1.37.0-eksbuild.32" ;;
  *) echo "No documented pin table for ${k8s}." >&2; exit 1 ;;
esac
print_latest aws-ebs-csi-driver "v1.67.2-eksbuild.1"
print_latest eks-pod-identity-agent "(unset resolves most_recent)"

echo
echo "aws_first is the first version returned by describe-addon-versions, which is the newest build AWS is advertising. It is not always the defaultVersion. Inspect compatibilities[].defaultVersion before you change a pin."
