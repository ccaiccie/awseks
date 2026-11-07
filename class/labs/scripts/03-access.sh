#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating
if [[ -z "$(get admin-entry)" ]]; then
 aws eks create-access-entry --cluster-name "$STACK" --principal-arn "$ADMIN_ROLE_ARN" --type STANDARD --tags "EksClassStack=$STACK"
 put admin-entry "$ADMIN_ROLE_ARN"
fi
# Elevated bootstrap permission is explicit, only for the sandbox administrator role.
aws eks associate-access-policy --cluster-name "$STACK" --principal-arn "$ADMIN_ROLE_ARN" --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster
export KUBECONFIG="$STATE_DIR/kubeconfig"
aws eks update-kubeconfig --name "$STACK" --region "$AWS_REGION" --role-arn "$ADMIN_ROLE_ARN" --alias "$STACK" --kubeconfig "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
# Calling identity must be allowed sts:AssumeRole to ADMIN_ROLE_ARN, even if it is the current role.
# If operating directly as that role and self-assume is not allowed, omit --role-arn from
# update-kubeconfig deliberately and keep short-lived role credentials for every kubectl invocation.
ctx
kubectl wait --for=condition=Ready nodes --all --timeout=600s
kubectl get nodes -o wide
kubectl -n kube-system get pods -o wide
kubectl -n kube-system get configmap kube-proxy-config -o yaml > "$STATE_DIR/kube-proxy-config.yaml"
kubectl -n kube-system logs daemonset/kube-proxy --tail=100 > "$STATE_DIR/kube-proxy.log"
# Verify deployed implementation, do not infer it solely from generic EKS documentation.
python3 - "$STATE_DIR/kube-proxy-config.yaml" "$STATE_DIR/kube-proxy.log" <<'PY'
import pathlib,re,sys
cfg,log=(pathlib.Path(p).read_text() for p in sys.argv[1:])
assert re.search(r'mode:\s*[\'\"]?iptables',cfg) or re.search(r'Using iptables Proxier',log,re.I), 'Proxy mode not proven iptables; inspect config/logs. Do not claim canonical packet semantics until verified.'
PY
kubectl auth can-i create deployments -n default
echo 'Expected illustrative: nodes Ready; system pods Running; yes. Pending/Degraded is not success.'
