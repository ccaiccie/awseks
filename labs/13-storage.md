# Lab 13 — EBS CSI, Availability Zones, and optional EFS

## Objective

Create a 1 GiB encrypted gp3 volume in the same AZ as the pod, and see why a second pod on the other node cannot mount it.

## Architecture

The EBS CSI controller uses the Pod Identity role from stack 02, service account `ebs-csi-controller-sa`. The node role is not that role. `volumeBindingMode: WaitForFirstConsumer` waits for the scheduler so the volume is created in the pod's AZ. EBS is ReadWriteOnce and zonal.

EFS is optional, ReadWriteMany, and billed. It is not created unless stack 03 has `enable_efs` and `efs_confirmation = "enable-efs"`.

## Prerequisites

Stack 02 applied, so the EBS addon is present. `kubectl get sc` may already show a storage class from the addon. The lab file creates `lab-gp3` and does not mark it default.

## Steps

```bash
kubectl apply -f manifests/lab13-storage/ebs.yaml
kubectl -n lab-storage get pvc web-data
kubectl -n lab-storage get pod -o wide
PV="$(kubectl -n lab-storage get pvc web-data -o jsonpath='{.spec.volumeName}')"
kubectl get pv "$PV" -o jsonpath='{.spec.nodeAffinity}{"\n"}'
aws ec2 describe-volumes --filters Name=tag:kubernetes.io/created-for/pvc/name,Values=web-data \
  --query 'Volumes[].{Id:VolumeId,AZ:AvailabilityZone,Size:Size,Type:VolumeType,Encrypted:Encrypted}'
```

## Expected observations

Example only. The PVC becomes Bound. The volume AZ matches the node AZ. The volume is gp3, 1 GiB, encrypted. The pod is Running. A second replica would stay Pending if you raised replicas while the volume is ReadWriteOnce and already attached.

## Questions

1. Why does the Deployment use strategy Recreate?
2. What does reclaim policy Delete do when the PVC is deleted?
3. Why is EFS not in the default apply?

## Failure injection

Optional. Cordon the node where the pod runs and delete the pod. The new pod stays Pending if it is scheduled to the other AZ, because the volume cannot move. Uncordon the node and delete the pod again so it returns.

```bash
kubectl cordon "$NODE"
kubectl -n lab-storage delete pod -l app.kubernetes.io/name=ebs-web
kubectl uncordon "$NODE"
```

## EFS, only if you opted in

Replace `EFS_FILE_SYSTEM_ID` in `manifests/lab13-storage/efs-opt-in.yaml` with the stack 03 output. Apply it after the EFS CSI addon pods are Ready. The persistent volume reclaim policy is Retain. Deleting the claim does not delete the file system. Stack 03 destroy does.

## Diagnostics

PVC Pending with `WaitForFirstConsumer` and no pod: the Deployment did not schedule. PVC Pending with a provisioning error: the controller log in `kube-system` for `ebs-csi-controller`. `AccessDenied` on `ec2:CreateVolume` is the Pod Identity role, not the node. Volume encrypted false means you applied a different StorageClass.

## Answers

1. RollingUpdate would run two pods during the replace. The second cannot attach a ReadWriteOnce volume that is already attached. Recreate stops the old pod first.
2. The addon deletes the EBS volume after the claim is gone. `Retain` would leave the volume and the bill. The lab class is Delete. The EFS sample is Retain on purpose so you see the difference.
3. EFS charges for storage and for a mount target in each subnet. The class default keeps that off.

## Cleanup

```bash
kubectl delete namespace lab-storage
```

Wait until the PVC is gone, then confirm the volume is gone:

```bash
aws ec2 describe-volumes --filters Name=tag:Project,Values=awseks-practice Name=status,Values=available
```

An available volume is a leftover. Delete only the one this lab created.

## Cost

1 GiB of gp3 for as long as the PVC exists, plus the snapshot you did not create. EFS, if enabled, is the larger line. Delete it with stack 03 when you are done.
