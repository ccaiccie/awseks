#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx
# Requires explicit known runner SG; never opens the private API to arbitrary internet CIDRs.
: "${RUNNER_SG_ID:?Set an existing approved runner SG in this SAME VPC}"
VPC=$(aws ec2 describe-security-groups --group-ids "$RUNNER_SG_ID" --query 'SecurityGroups[0].VpcId' --output text)
[[ "$VPC" == "$(get vpc)" ]] || { echo 'Wrong runner VPC.' >&2; exit 1; }
if [[ -z "$(get private-runner-rule)" ]]; then
 RULE=$(aws ec2 authorize-security-group-ingress --group-id "$(get cluster-sg)" --ip-permissions "IpProtocol=tcp,FromPort=443,ToPort=443,UserIdGroupPairs=[{GroupId=$RUNNER_SG_ID,Description=eksclass-private-runner}]" --query 'SecurityGroupRules[0].SecurityGroupRuleId' --output text)
 put private-runner-rule "$RULE"
fi
[[ "${PRIVATE_RUNNER_CONFIRMED:-NO}" == I_TESTED_PRIVATE_DNS_AND_443 ]] || { echo 'STOP: first test an in-VPC runner/approved VPN, IAM role and private API DNS+443. See README L08.' >&2; exit 1; }
ID=$(aws eks update-cluster-config --name "$STACK" --resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true --query update.id --output text); put endpoint-update "$ID"
echo "Inspect update: aws eks describe-update --name $STACK --update-id $ID"
echo 'Then kubectl from PRIVATE runner. cluster-active waiter alone does not prove this config update finished.'
echo "Recovery (AWS service API, appropriate IAM required): aws eks update-cluster-config --name $STACK --resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true,publicAccessCidrs=$ADMIN_PUBLIC_CIDR"
