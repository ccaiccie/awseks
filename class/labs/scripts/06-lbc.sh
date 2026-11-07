#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; owned_vpc
for x in helm curl; do command -v "$x" >/dev/null; done
[[ "$LBC_CHART_VERSION" != REPLACE* ]] || { echo 'Review helm search repo eks/aws-load-balancer-controller --versions; choose chart whose appVersion is v3.6.2.' >&2; exit 1; }
LBC_VERSION=v3.6.2
# Public static release artifact. Download does not authenticate to an account.
curl --fail --location --proto '=https' --tlsv1.2 "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/$LBC_VERSION/docs/install/iam_policy.json" -o "$STATE_DIR/lbc-policy.json"
jq -e '.Version=="2012-10-17" and (.Statement|length>0)' "$STATE_DIR/lbc-policy.json" >/dev/null
printf '%s  %s\n' '16f232c9d9f79366fe949c4550ad517a202380058a9e48d45a4e215044a20a6a' "$STATE_DIR/lbc-policy.json" | sha256sum --check
sha256sum "$STATE_DIR/lbc-policy.json" > "$STATE_DIR/lbc-policy.sha256"
POLICY=$(ensure lbc-policy aws iam create-policy --policy-name "$STACK-lbc" --policy-document "file://$STATE_DIR/lbc-policy.json" --tags Key=EksClassStack,Value="$STACK" --query Policy.Arn --output text)
# Reuse the generated restrictive Pod Identity trust with only the service-account name changed.
python3 - "$STATE_DIR/cni-trust.json" > "$STATE_DIR/lbc-trust.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]));x['Statement'][0]['Condition']['StringEquals']['aws:RequestTag/kubernetes-service-account']='aws-load-balancer-controller';print(json.dumps(x))
PY
ROLE=$(role lbc-role "$STACK-lbc" "$STATE_DIR/lbc-trust.json" "$POLICY")
if [[ -z "$(get lbc-association)" ]]; then
 ID=$(aws eks create-pod-identity-association --cluster-name "$STACK" --namespace kube-system --service-account aws-load-balancer-controller --role-arn "$ROLE" --tags "EksClassStack=$STACK" --query association.associationId --output text); put lbc-association "$ID"
fi
helm repo add eks https://aws.github.io/eks-charts --force-update
helm repo update eks
helm show chart eks/aws-load-balancer-controller --version "$LBC_CHART_VERSION" > "$STATE_DIR/lbc-chart.yaml"
python3 - "$STATE_DIR/lbc-chart.yaml" <<'PY'
import pathlib,re,sys
s=pathlib.Path(sys.argv[1]).read_text();assert re.search(r'appVersion:\s*[\'\"]?v?3\.6\.2(?:[\'\"])?\s*$',s,re.M), 'Chart appVersion differs from verified controller version'
PY
# Fresh install: Helm installs its bundled CRDs. Upgrades require separately reviewed CRD updates.
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller --version "$LBC_CHART_VERSION" -n kube-system --set clusterName="$STACK" --set region="$AWS_REGION" --set vpcId="$(get vpc)" --set serviceAccount.create=true --set serviceAccount.name=aws-load-balancer-controller --set enableServiceMutatorWebhook=false --wait --timeout 10m
put lbc-installed yes
kubectl -n kube-system rollout status deployment/aws-load-balancer-controller --timeout=300s
kubectl get ingressclass
# Generated cluster SG self-allow permits node webhook 9443 from control-plane ENIs.
echo 'LBC gets own IAM role, not node credentials. No load balancer exists until service/Ingress intent.'
