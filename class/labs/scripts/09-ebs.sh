#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"; mutating; ctx; image_guard "$APP_IMAGE"
python3 - "$STATE_DIR/cni-trust.json" > "$STATE_DIR/ebs-trust.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]));x['Statement'][0]['Condition']['StringEquals']['aws:RequestTag/kubernetes-service-account']='ebs-csi-controller-sa';print(json.dumps(x))
PY
ROLE=$(role ebs-role "$STACK-ebs" "$STATE_DIR/ebs-trust.json" arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2)
VER=$(addon_version aws-ebs-csi-driver)
if [[ -z "$(get created-aws-ebs-csi-driver)" ]]; then
 aws eks create-addon --cluster-name "$STACK" --addon-name aws-ebs-csi-driver --addon-version "$VER" --pod-identity-associations "serviceAccount=ebs-csi-controller-sa,roleArn=$ROLE" --tags "EksClassStack=$STACK"
 put created-aws-ebs-csi-driver yes
fi
aws eks wait addon-active --cluster-name "$STACK" --addon-name aws-ebs-csi-driver
python3 - "$LAB_ROOT/manifests/storage.yaml" "$APP_IMAGE" > "$STATE_DIR/storage.yaml" <<'PY'
import pathlib,sys
print(pathlib.Path(sys.argv[1]).read_text().replace('registry.k8s.io/e2e-test-images/agnhost:2.53',sys.argv[2]))
PY
kubectl apply --dry-run=server -f "$STATE_DIR/storage.yaml"
kubectl apply -f "$STATE_DIR/storage.yaml"
kubectl -n eksclass rollout status deployment/volume-demo --timeout=600s
kubectl -n eksclass get pvc data -o wide
PV=$(kubectl -n eksclass get pvc data -o jsonpath='{.spec.volumeName}'); put pv "$PV"
VOL=$(kubectl get pv "$PV" -o jsonpath='{.spec.csi.volumeHandle}'); put ebs-volume "$VOL"
aws ec2 describe-volumes --volume-ids "$VOL" --query 'Volumes[].{ID:VolumeId,AZ:AvailabilityZone,Encrypted:Encrypted,State:State}'
echo 'Write/read test: kubectl exec deploy/volume-demo -- sh requires a shell-capable reviewed image; do not assume every minimal image contains sh.'
echo 'Deletion of data PVC with Delete reclaim policy destroys this disk. Back up before cleanup if you want data.'
