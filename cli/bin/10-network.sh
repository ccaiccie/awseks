#!/usr/bin/env bash
# Create the lab VPC. Safe to re-run: recorded ids are reused, untracked tagged resources stop the script.
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

load_config
require_cmd aws
require_cmd python3
[[ -n "$(state_get ACCOUNT_ID || true)" ]] || die "Run cli/bin/00-preflight.sh first."

read -r -a azs <<<"$(state_get AVAILABILITY_ZONES)"
[[ "${#azs[@]}" -ge "${AZ_COUNT}" ]] || die "Availability Zone list is missing. Re-run preflight."

find_tagged() {
  local resource_name="$1"
  aws_cli ec2 describe-vpcs \
    --filters "Name=tag:Cluster,Values=${CLUSTER_NAME}" "Name=tag:Provisioner,Values=awscli" "Name=tag:Name,Values=${resource_name}" \
    --query 'Vpcs[0].VpcId' --output text
}

if [[ -z "$(state_get VPC_ID || true)" ]]; then
  found="$(find_tagged "${CLUSTER_NAME}-vpc")"
  [[ -z "${found}" || "${found}" == "None" ]] || die "VPC ${found} is already tagged for ${CLUSTER_NAME} but is not in ${STATE_FILE}. Refusing to create another."
  vpc_id="$(aws_cli ec2 create-vpc --cidr-block "${VPC_CIDR}" --query 'Vpc.VpcId' --output text)"
  aws_cli ec2 modify-vpc-attribute --vpc-id "${vpc_id}" --enable-dns-support '{"Value":true}'
  aws_cli ec2 modify-vpc-attribute --vpc-id "${vpc_id}" --enable-dns-hostnames '{"Value":true}'
  tag_resource "${vpc_id}" "${CLUSTER_NAME}-vpc"
  state_set VPC_ID "${vpc_id}"
  checkpoint "vpc ${vpc_id}"
else
  vpc_id="$(state_get VPC_ID)"
  assert_owned_vpc "${vpc_id}"
  info "Reusing VPC ${vpc_id}"
fi

if [[ -z "$(state_get IGW_ID || true)" ]]; then
  igw_id="$(aws_cli ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)"
  tag_resource "${igw_id}" "${CLUSTER_NAME}-igw"
  aws_cli ec2 attach-internet-gateway --internet-gateway-id "${igw_id}" --vpc-id "${vpc_id}"
  state_set IGW_ID "${igw_id}"
  checkpoint "igw ${igw_id}"
else
  igw_id="$(state_get IGW_ID)"
  info "Reusing internet gateway ${igw_id}"
fi

if [[ -z "$(state_get PUBLIC_SUBNET_IDS || true)" ]]; then
  public_ids=()
  for ((i = 0; i < AZ_COUNT; i++)); do
    cidr="$(subnet_cidr "${i}")"
    subnet_id="$(aws_cli ec2 create-subnet --vpc-id "${vpc_id}" --cidr-block "${cidr}" --availability-zone "${azs[$i]}" --query 'Subnet.SubnetId' --output text)"
    aws_cli ec2 modify-subnet-attribute --subnet-id "${subnet_id}" --map-public-ip-on-launch Value=true
    tag_resource "${subnet_id}" "${CLUSTER_NAME}-public-${azs[$i]}"
    aws_cli ec2 create-tags --resources "${subnet_id}" --tags Key=kubernetes.io/role/elb,Value=1 Key=Tier,Value=public
    public_ids+=("${subnet_id}")
  done
  state_set PUBLIC_SUBNET_IDS "$(IFS=,; echo "${public_ids[*]}")"
  checkpoint "public-subnets $(state_get PUBLIC_SUBNET_IDS)"
fi

if [[ -z "$(state_get PRIVATE_SUBNET_IDS || true)" ]]; then
  private_ids=()
  for ((i = 0; i < AZ_COUNT; i++)); do
    cidr="$(subnet_cidr "$((i + 10))")"
    subnet_id="$(aws_cli ec2 create-subnet --vpc-id "${vpc_id}" --cidr-block "${cidr}" --availability-zone "${azs[$i]}" --query 'Subnet.SubnetId' --output text)"
    tag_resource "${subnet_id}" "${CLUSTER_NAME}-private-${azs[$i]}"
    aws_cli ec2 create-tags --resources "${subnet_id}" --tags Key=kubernetes.io/role/internal-elb,Value=1 Key=Tier,Value=private
    private_ids+=("${subnet_id}")
  done
  state_set PRIVATE_SUBNET_IDS "$(IFS=,; echo "${private_ids[*]}")"
  checkpoint "private-subnets $(state_get PRIVATE_SUBNET_IDS)"
fi

IFS=',' read -r -a public_ids <<<"$(state_get PUBLIC_SUBNET_IDS)"
IFS=',' read -r -a private_ids <<<"$(state_get PRIVATE_SUBNET_IDS)"

if [[ -z "$(state_get PUBLIC_ROUTE_TABLE_ID || true)" ]]; then
  public_rt="$(aws_cli ec2 create-route-table --vpc-id "${vpc_id}" --query 'RouteTable.RouteTableId' --output text)"
  tag_resource "${public_rt}" "${CLUSTER_NAME}-public"
  aws_cli ec2 create-route --route-table-id "${public_rt}" --destination-cidr-block 0.0.0.0/0 --gateway-id "${igw_id}" >/dev/null
  for subnet_id in "${public_ids[@]}"; do
    aws_cli ec2 associate-route-table --route-table-id "${public_rt}" --subnet-id "${subnet_id}" >/dev/null
  done
  state_set PUBLIC_ROUTE_TABLE_ID "${public_rt}"
  checkpoint "public-route-table ${public_rt}"
fi

if [[ "${NAT_STRATEGY}" != "none" && -z "$(state_get NAT_GATEWAY_IDS || true)" ]]; then
  nat_count="${AZ_COUNT}"
  [[ "${NAT_STRATEGY}" == "single" ]] && nat_count=1
  nat_ids=()
  eip_ids=()
  for ((i = 0; i < nat_count; i++)); do
    allocation_id="$(aws_cli ec2 allocate-address --domain vpc --query 'AllocationId' --output text)"
    tag_resource "${allocation_id}" "${CLUSTER_NAME}-nat-${i}"
    nat_id="$(aws_cli ec2 create-nat-gateway --subnet-id "${public_ids[$i]}" --allocation-id "${allocation_id}" --query 'NatGateway.NatGatewayId' --output text)"
    tag_resource "${nat_id}" "${CLUSTER_NAME}-nat-${i}"
    info "Waiting for NAT gateway ${nat_id} to become available."
    for _ in $(seq 1 60); do
      nat_state="$(aws_cli ec2 describe-nat-gateways --nat-gateway-ids "${nat_id}" --query 'NatGateways[0].State' --output text)"
      [[ "${nat_state}" == "available" ]] && break
      [[ "${nat_state}" == "failed" ]] && die "NAT gateway ${nat_id} entered state failed."
      sleep 10
    done
    [[ "${nat_state}" == "available" ]] || die "Timed out waiting for NAT gateway ${nat_id}."
    nat_ids+=("${nat_id}")
    eip_ids+=("${allocation_id}")
  done
  state_set NAT_GATEWAY_IDS "$(IFS=,; echo "${nat_ids[*]}")"
  state_set EIP_ALLOCATION_IDS "$(IFS=,; echo "${eip_ids[*]}")"
  checkpoint "nat $(state_get NAT_GATEWAY_IDS)"
fi

if [[ -z "$(state_get PRIVATE_ROUTE_TABLE_IDS || true)" ]]; then
  private_rts=()
  if [[ "${NAT_STRATEGY}" == "per_az" ]]; then
    IFS=',' read -r -a nat_ids <<<"$(state_get NAT_GATEWAY_IDS)"
    for ((i = 0; i < AZ_COUNT; i++)); do
      private_rt="$(aws_cli ec2 create-route-table --vpc-id "${vpc_id}" --query 'RouteTable.RouteTableId' --output text)"
      tag_resource "${private_rt}" "${CLUSTER_NAME}-private-${azs[$i]}"
      aws_cli ec2 create-route --route-table-id "${private_rt}" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "${nat_ids[$i]}" >/dev/null
      aws_cli ec2 associate-route-table --route-table-id "${private_rt}" --subnet-id "${private_ids[$i]}" >/dev/null
      private_rts+=("${private_rt}")
    done
  else
    private_rt="$(aws_cli ec2 create-route-table --vpc-id "${vpc_id}" --query 'RouteTable.RouteTableId' --output text)"
    tag_resource "${private_rt}" "${CLUSTER_NAME}-private-shared"
    if [[ "${NAT_STRATEGY}" == "single" ]]; then
      aws_cli ec2 create-route --route-table-id "${private_rt}" --destination-cidr-block 0.0.0.0/0 --nat-gateway-id "$(state_get NAT_GATEWAY_IDS)" >/dev/null
    fi
    for subnet_id in "${private_ids[@]}"; do
      aws_cli ec2 associate-route-table --route-table-id "${private_rt}" --subnet-id "${subnet_id}" >/dev/null
    done
    private_rts+=("${private_rt}")
  fi
  state_set PRIVATE_ROUTE_TABLE_IDS "$(IFS=,; echo "${private_rts[*]}")"
  checkpoint "private-route-tables $(state_get PRIVATE_ROUTE_TABLE_IDS)"
fi

if [[ -z "$(state_get API_SG_ID || true)" ]]; then
  api_sg="$(aws_cli ec2 create-security-group --group-name "${CLUSTER_NAME}-api" --description "In-VPC clients to the private EKS API" --vpc-id "${vpc_id}" --query 'GroupId' --output text)"
  tag_resource "${api_sg}" "${CLUSTER_NAME}-api"
  aws_cli ec2 authorize-security-group-ingress --group-id "${api_sg}" --ip-permissions "IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=${VPC_CIDR},Description=private API from VPC}]"
  aws_cli ec2 revoke-security-group-egress --group-id "${api_sg}" --ip-permissions 'IpProtocol=-1,IpRanges=[{CidrIp=0.0.0.0/0}]'
  aws_cli ec2 authorize-security-group-egress --group-id "${api_sg}" --ip-permissions "IpProtocol=-1,IpRanges=[{CidrIp=${VPC_CIDR},Description=return traffic inside the VPC}]"
  state_set API_SG_ID "${api_sg}"
  checkpoint "api-security-group ${api_sg}"
fi

if [[ -z "$(state_get ENDPOINT_SG_ID || true)" ]]; then
  endpoint_sg="$(aws_cli ec2 create-security-group --group-name "${CLUSTER_NAME}-endpoints" --description "HTTPS from the VPC to interface endpoints" --vpc-id "${vpc_id}" --query 'GroupId' --output text)"
  tag_resource "${endpoint_sg}" "${CLUSTER_NAME}-endpoints"
  aws_cli ec2 authorize-security-group-ingress --group-id "${endpoint_sg}" --ip-permissions "IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges=[{CidrIp=${VPC_CIDR},Description=HTTPS to interface endpoints}]"
  state_set ENDPOINT_SG_ID "${endpoint_sg}"
  checkpoint "endpoint-security-group ${endpoint_sg}"
fi

if [[ -z "$(state_get S3_ENDPOINT_ID || true)" ]]; then
  IFS=',' read -r -a private_rts <<<"$(state_get PRIVATE_ROUTE_TABLE_IDS)"
  s3_endpoint="$(aws_cli ec2 create-vpc-endpoint \
    --vpc-id "${vpc_id}" \
    --service-name "com.amazonaws.${AWS_REGION}.s3" \
    --vpc-endpoint-type Gateway \
    --route-table-ids "${private_rts[@]}" \
    --tag-specifications "ResourceType=vpc-endpoint,Tags=[{Key=Name,Value=${CLUSTER_NAME}-s3},{Key=Project,Value=awseks-practice},{Key=Provisioner,Value=awscli},{Key=Cluster,Value=${CLUSTER_NAME}}]" \
    --query 'VpcEndpoint.VpcEndpointId' --output text)"
  state_set S3_ENDPOINT_ID "${s3_endpoint}"
  checkpoint "s3-gateway-endpoint ${s3_endpoint}"
fi

if [[ "${ENABLE_INTERFACE_ENDPOINTS}" == "true" && -z "$(state_get INTERFACE_ENDPOINT_IDS || true)" ]]; then
  services=(ecr.api ecr.dkr eks-auth ec2 sts logs elasticloadbalancing autoscaling)
  endpoint_ids=()
  for service in "${services[@]}"; do
    endpoint_id="$(aws_cli ec2 create-vpc-endpoint \
      --vpc-id "${vpc_id}" \
      --service-name "com.amazonaws.${AWS_REGION}.${service}" \
      --vpc-endpoint-type Interface \
      --subnet-ids "${private_ids[@]}" \
      --security-group-ids "$(state_get ENDPOINT_SG_ID)" \
      --private-dns-enabled \
      --tag-specifications "ResourceType=vpc-endpoint,Tags=[{Key=Name,Value=${CLUSTER_NAME}-${service}},{Key=Project,Value=awseks-practice},{Key=Provisioner,Value=awscli},{Key=Cluster,Value=${CLUSTER_NAME}}]" \
      --query 'VpcEndpoint.VpcEndpointId' --output text)"
    endpoint_ids+=("${endpoint_id}")
  done
  state_set INTERFACE_ENDPOINT_IDS "$(IFS=,; echo "${endpoint_ids[*]}")"
  checkpoint "interface-endpoints $(state_get INTERFACE_ENDPOINT_IDS)"
fi

info "Network checkpoint complete. VPC $(state_get VPC_ID). Private subnets are for nodes and the control plane ENIs."
info "Expected next: cli/bin/20-iam.sh"
