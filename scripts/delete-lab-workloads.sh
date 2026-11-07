#!/usr/bin/env bash
# Delete student lab namespaces and wait for LoadBalancer and volume finalizers.
# Does not run terraform destroy and does not delete kube-system.
set -euo pipefail

if [[ "${CONFIRM:-}" != "delete-lab-workloads" ]]; then
  echo "Refusing to delete anything. Re-run with CONFIRM=delete-lab-workloads CLUSTER_NAME=<name>." >&2
  exit 1
fi

cluster="${CLUSTER_NAME:-}"
if [[ -z "$cluster" ]]; then
  echo "Set CLUSTER_NAME to the context you intend to clean." >&2
  exit 1
fi

current="$(kubectl config current-context)"
if [[ "$current" != *"$cluster"* ]]; then
  echo "Current context '${current}' does not contain CLUSTER_NAME '${cluster}'." >&2
  exit 1
fi

namespaces=(
  lab-fundamentals
  lab-dns
  lab-cni
  lab-netpol
  lab-identity
  lab-ingress
  lab-nlb
  lab-storage
  lab-hpa
  lab-gateway
  lab-upgrade
  lab-observe
)

echo "Deleting lab namespaces from context ${current}."
for ns in "${namespaces[@]}"; do
  if kubectl get namespace "$ns" >/dev/null 2>&1; then
    kubectl delete namespace "$ns" --wait=false
  else
    echo "namespace/${ns} already absent"
  fi
done

echo "Waiting for namespaces to finish finalizers (load balancers and volumes)."
for ns in "${namespaces[@]}"; do
  kubectl wait --for=delete "namespace/${ns}" --timeout=600s >/dev/null 2>&1 || true
  if kubectl get namespace "$ns" >/dev/null 2>&1; then
    echo "namespace/${ns} is still terminating. Inspect finalizers before you destroy the cluster:" >&2
    kubectl get namespace "$ns" -o jsonpath='{.metadata.finalizers}{"\n"}' >&2 || true
    kubectl get service,ingress,pvc -n "$ns" >&2 || true
    exit 1
  fi
done

echo "Lab namespaces are gone. Controllers, nodes, the cluster, and the VPC are still Terraform's. Follow docs/CLEANUP.md."
