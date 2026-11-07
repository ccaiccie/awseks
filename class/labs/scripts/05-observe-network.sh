#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; ctx
kubectl -n eksclass get pods -o wide
kubectl -n eksclass get service web -o jsonpath='{.spec.clusterIP}{"\n"}'
kubectl -n eksclass get endpointslices -l kubernetes.io/service-name=web -o yaml
kubectl -n kube-system get daemonset aws-node -o yaml > "$STATE_DIR/aws-node-observed.yaml"
kubectl -n kube-system get deployment coredns -o yaml > "$STATE_DIR/coredns-observed.yaml"
aws ec2 describe-subnets --subnet-ids "$(get private-a)" "$(get private-b)" --query 'Subnets[].{AZ:AvailabilityZone,CIDR:CidrBlock,Free:AvailableIpAddressCount}'
aws ec2 describe-network-interfaces --filters Name=vpc-id,Values="$(get vpc)" --query 'NetworkInterfaces[].{ENI:NetworkInterfaceId,IP:PrivateIpAddress,Secondary:PrivateIpAddresses,Prefixes:Ipv4Prefixes,Description:Description}'
aws ec2 describe-route-tables --filters Name=vpc-id,Values="$(get vpc)"
echo 'Observe actual IPs; illustrative diagram addresses are not deployment output.'
echo 'Optional isolated debug Pod: see README L05. Do not deploy a privileged node inspector in this lab.'
