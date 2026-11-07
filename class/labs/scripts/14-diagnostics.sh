#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; ctx
aws eks describe-cluster --name "$STACK" --query 'cluster.{Status:status,Health:health,Endpoint:resourcesVpcConfig,Version:version}'
aws eks describe-nodegroup --cluster-name "$STACK" --nodegroup-name "$STACK-ng" --query 'nodegroup.{Status:status,Health:health}'
kubectl get nodes -o wide
kubectl -n eksclass get deployment,pods,service,endpointslices,ingress,pvc,hpa -o wide
kubectl -n eksclass get events --sort-by=.metadata.creationTimestamp
kubectl -n kube-system logs daemonset/aws-node -c aws-node --tail=100
kubectl -n kube-system logs deployment/coredns --tail=100
if [[ "$(get lbc-installed)" == yes ]]; then kubectl -n kube-system logs deployment/aws-load-balancer-controller --tail=100; fi
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/$STACK/cluster" --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays,Bytes:storedBytes}'
echo 'No secrets, token files or credentials dumped. Review logs before sharing; app/audit content may be sensitive.'
