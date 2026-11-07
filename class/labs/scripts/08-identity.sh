#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$AWSCLI_IMAGE"
# One role for a teaching service account. s3:GetObject only to a deliberately non-existent
# teaching prefix until learner supplies an owned test bucket and reviews a scoped policy.
python3 - "$STATE_DIR/cni-trust.json" > "$STATE_DIR/workload-trust.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); c=x['Statement'][0]['Condition']['StringEquals'];c['aws:RequestTag/kubernetes-namespace']='eksclass';c['aws:RequestTag/kubernetes-service-account']='aws-reader';print(json.dumps(x))
PY
ROLE=$(role workload-role "$STACK-reader" "$STATE_DIR/workload-trust.json")
cat > "$STATE_DIR/reader-policy.json" <<JSON
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:GetObject","Resource":"arn:aws:s3:::$STACK-$ACCOUNT/teaching/*"}]}
JSON
aws iam put-role-policy --role-name "$STACK-reader" --policy-name ReadTeachingPrefix --policy-document "file://$STATE_DIR/reader-policy.json"
kubectl -n eksclass create serviceaccount aws-reader --dry-run=client -o yaml | kubectl apply -f -
if [[ -z "$(get workload-association)" ]]; then
 ID=$(aws eks create-pod-identity-association --cluster-name "$STACK" --namespace eksclass --service-account aws-reader --role-arn "$ROLE" --tags "EksClassStack=$STACK" --query association.associationId --output text); put workload-association "$ID"
fi
# kubectl run cannot set serviceAccountName directly; generate a complete Pod manifest.
cat > "$STATE_DIR/identity-check.yaml" <<YAML
apiVersion: v1
kind: Pod
metadata: {name: identity-check, namespace: eksclass}
spec:
  restartPolicy: Never
  serviceAccountName: aws-reader
  securityContext: {runAsNonRoot: true, runAsUser: 1000, seccompProfile: {type: RuntimeDefault}}
  containers:
  - name: aws
    image: $AWSCLI_IMAGE
    command: [aws]
    args: [sts, get-caller-identity, --region, $AWS_REGION]
    env: [{name: HOME, value: /tmp}]
    securityContext: {allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: {drop: [ALL]}}
    resources: {requests: {cpu: 50m, memory: 64Mi}, limits: {cpu: 250m, memory: 256Mi}}
    volumeMounts: [{name: tmp, mountPath: /tmp}]
  volumes: [{name: tmp, emptyDir: {}}]
YAML
kubectl apply -f "$STATE_DIR/identity-check.yaml"
echo 'Association is eventually consistent. Inspect Pod status and logs after it completes; recreate EXACT identity-check Pod if started before association converged.'
kubectl -n eksclass get pod identity-check
kubectl -n eksclass logs identity-check || { echo 'Not ready yet: inspect events, then retry logs; no success claimed.' >&2; exit 1; }
echo 'Expected ARN shape arn:aws:sts::<account>:assumed-role/<stack>-reader/<session>; never node role.'
echo 'No S3 bucket or data created. A successful STS identity check does not prove S3 authorization.'
