#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; owned_vpc
jq -e --arg v "$K8S_VERSION" '.clusterVersions[] | select(.clusterVersion==$v)' "$STATE_DIR/cluster-versions.json" >/dev/null
cat > "$STATE_DIR/cluster-trust.json" <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
cat > "$STATE_DIR/node-trust.json" <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
CLUSTER_ROLE=$(role cluster-role "$STACK-cluster" "$STATE_DIR/cluster-trust.json" arn:aws:iam::aws:policy/AmazonEKSClusterPolicy)
NODE_ROLE=$(role node-role "$STACK-node" "$STATE_DIR/node-trust.json" arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly)
# Dedicated CNI allocation role. Trust limited to this cluster namespace/service account.
python3 - "$ACCOUNT" "$AWS_REGION" "$STACK" > "$STATE_DIR/cni-trust.json" <<'PY'
import json,sys
a,r,c=sys.argv[1:]
print(json.dumps({'Version':'2012-10-17','Statement':[{'Effect':'Allow','Principal':{'Service':'pods.eks.amazonaws.com'},'Action':['sts:AssumeRole','sts:TagSession'],'Condition':{'StringEquals':{'aws:RequestTag/kubernetes-namespace':'kube-system','aws:RequestTag/kubernetes-service-account':'aws-node','aws:RequestTag/eks-cluster-arn':f'arn:aws:eks:{r}:{a}:cluster/{c}'}}}]}))
PY
CNI_ROLE=$(role cni-role "$STACK-cni" "$STATE_DIR/cni-trust.json" arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy)
# IAM is eventually consistent; if create-cluster reports InvalidParameterException for a new role,
# retry after propagation after inspecting the exact error; never swallow AccessDenied.
if [[ -z "$(get cluster-arn)" ]]; then
 ARN=$(aws eks create-cluster --name "$STACK" --kubernetes-version "$K8S_VERSION" --role-arn "$CLUSTER_ROLE" --resources-vpc-config "subnetIds=$(get private-a),$(get private-b),endpointPrivateAccess=true,endpointPublicAccess=true,publicAccessCidrs=$ADMIN_PUBLIC_CIDR" --kubernetes-network-config ipFamily=ipv4,serviceIpv4Cidr=172.20.0.0/16 --access-config authenticationMode=API,bootstrapClusterCreatorAdminPermissions=false --no-bootstrap-self-managed-addons --upgrade-policy supportType=STANDARD --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}' --tags "EksClassStack=$STACK" --query cluster.arn --output text)
 put cluster-arn "$ARN"
fi
aws eks wait cluster-active --name "$STACK"
SG=$(aws eks describe-cluster --name "$STACK" --query cluster.resourcesVpcConfig.clusterSecurityGroupId --output text); put cluster-sg "$SG"
aws ec2 describe-security-groups --group-ids "$SG"
# EKS's default cluster SG self ingress and egress are deliberately retained for functional
# node/kubelet/DNS/webhook paths in this training stack; production restriction is a separate exercise.
# No 0/0 INGRESS or SSH is created. Public API is restricted independently by the EKS /32.
for addon in eks-pod-identity-agent vpc-cni kube-proxy coredns; do
 VER=$(addon_version "$addon")
 if [[ -z "$(get "created-$addon")" ]]; then
  EXTRA=()
  if [[ "$addon" == vpc-cni ]]; then EXTRA+=(--pod-identity-associations "serviceAccount=aws-node,roleArn=$CNI_ROLE" --configuration-values '{"enableNetworkPolicy":"true"}'); fi
  aws eks create-addon --cluster-name "$STACK" --addon-name "$addon" --addon-version "$VER" "${EXTRA[@]}" --tags "EksClassStack=$STACK" > "$STATE_DIR/$addon-created.json"
  put "created-$addon" yes
 fi
done
# CoreDNS cannot be ACTIVE without worker capacity. Do not wait for all addons here.
cat > "$STATE_DIR/launch-template.json" <<'JSON'
{"MetadataOptions":{"HttpTokens":"required","HttpPutResponseHopLimit":1,"HttpEndpoint":"enabled"},"BlockDeviceMappings":[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":30,"VolumeType":"gp3","Encrypted":true,"DeleteOnTermination":true}}]}
JSON
LT=$(ensure launch-template aws ec2 create-launch-template --launch-template-name "$STACK-nodes" --launch-template-data "file://$STATE_DIR/launch-template.json" --tag-specifications "ResourceType=launch-template,Tags=[{Key=EksClassStack,Value=$STACK}]" --query LaunchTemplate.LaunchTemplateId --output text)
if [[ -z "$(get nodegroup-arn)" ]]; then
 NG=$(aws eks create-nodegroup --cluster-name "$STACK" --nodegroup-name "$STACK-ng" --subnets "$(get private-a)" "$(get private-b)" --node-role "$NODE_ROLE" --ami-type AL2023_x86_64_STANDARD --instance-types "$INSTANCE_TYPE" --capacity-type ON_DEMAND --scaling-config "minSize=2,maxSize=4,desiredSize=$NODE_DESIRED" --launch-template "id=$LT,version=1" --update-config maxUnavailable=1 --tags "EksClassStack=$STACK" --query nodegroup.nodegroupArn --output text)
 put nodegroup-arn "$NG"
fi
aws eks wait nodegroup-active --cluster-name "$STACK" --nodegroup-name "$STACK-ng"
for addon in eks-pod-identity-agent vpc-cni kube-proxy coredns; do aws eks wait addon-active --cluster-name "$STACK" --addon-name "$addon"; done
aws eks describe-nodegroup --cluster-name "$STACK" --nodegroup-name "$STACK-ng" --query 'nodegroup.{Status:status,Health:health,Scaling:scalingConfig}'
echo 'Control plane and node group ready. Continue access-entry setup; no kubeconfig assumed yet.'
