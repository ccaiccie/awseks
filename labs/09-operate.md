# Lab 09 — Storage, scale, upgrades, cleanup

## Objective

Bind a volume in one AZ, see why HPA is not node autoscaling, and plan a rollback without treating it as "EKS can never go back."

## Prerequisites

Labs 03 or 04. Diagrams F18, F19, F20, F21, F27, F28, F29 in `class/diagrams/`. [docs/versions.md](../docs/versions.md) for the 7-day rollback conditions.

## Commands

```bash
kubectl apply -f manifests/storage/storageclass-gp3.yaml
kubectl apply -f manifests/base/namespace.yaml
kubectl apply -f manifests/storage/pvc.yaml
kubectl apply -f manifests/scaling/pdb.yaml
kubectl apply -f manifests/scaling/hpa.yaml
```

The PVC stays Pending until a pod uses it (`WaitForFirstConsumer`). That is expected. Metrics for the HPA need the optional metrics-server stage. A PodDisruptionBudget of `minAvailable: 1` with two replicas allows one voluntary eviction. `minAvailable: 2` with two replicas would block drain. Do not install Cluster Autoscaler and Karpenter on the same nodes. Karpenter on Kubernetes 1.36 needs Karpenter >= 1.13 on the compatibility matrix fetched 2026-11-07. It is not installed here.

Read-only upgrade planning, not an upgrade:

```bash
aws eks list-insights --cluster-name "$CLUSTER_NAME"
aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.37 \
  --query 'addons[0].addonVersions[0].addonVersion'
```

Rollback exists only as documented in [docs/versions.md](../docs/versions.md): previous minor, within 7 days of a completed in-place upgrade, cluster ACTIVE, feature and insight checks. It does not restore an older etcd backup of your app, because this is not a customer etcd export.

## Expected observation

`gp3` provisioner is `ebs.csi.aws.com`. Auto Mode's provisioner `ebs.csi.eks.amazonaws.com` is a different owner and is not this cluster. The volume's AZ matches the node that mounted it.

## Question

Why can the control plane be multi-AZ while a PVC cannot fail over to the other AZ?

## Explanation

EKS runs the managed control plane across Availability Zones. An EBS volume is created in one AZ. `ReadWriteOnce` means one node at a time, not one pod, and not a second AZ.

## Safe failure

Scale the deployment to zero and describe the PVC. With `WaitForFirstConsumer` and no consumer, it does not create a disk in a random AZ. Scaling back up, after a pod is scheduled, is what binds it.

## Cost

A bound 1 GiB gp3 volume bills until the PVC is deleted. `reclaimPolicy: Delete` deletes that disk. HPA does not add nodes by itself.

## Cleanup

Delete the PVC and wait for the volume to disappear before you delete nodes. Full order is [docs/cleanup.md](../docs/cleanup.md). Class teardown is `class/labs/scripts/90-cleanup-apps.sh` then `91` and `92`, only for an `eksclass-cli-*` stack.
