# Lab 17 — Upgrades, drain, PDB, rolling nodes, and spot

## Objective

Move one minor version, keep one replica available, and see a spot node as a separate group that can disappear.

## Architecture

EKS upgrades the control plane first, then you upgrade the node group AMI. `max_unavailable = 1` on the managed group replaces nodes one at a time. A PodDisruptionBudget of `minAvailable: 1` refuses a voluntary eviction that would drop the Deployment below one ready pod. It does not stop a spot interruption or a dead AZ.

The spot group is optional, tainted, and desired 0 until you scale it. It is not the group the system pods use.

Supported minors in this repo are 1.34, 1.35, 1.36, and 1.37. Upgrade one minor at a time. 1.35 to 1.37 in one apply is not the procedure. Check the addon table in `docs/VERSIONS.md` for the target version before you change `kubernetes_version`. The stack selects addon versions from that map.

## Prerequisites

Stack 02. A quiet room, because the control plane upgrade takes time and cannot be hurried safely. `cluster_deletion_protection` can be true during the upgrade so a mistaken destroy fails.

## Steps

```bash
kubectl apply -f manifests/lab17-upgrade/pdb.yaml
kubectl -n lab-upgrade get pdb web
kubectl -n lab-upgrade get pods -o wide
```

Drain one node and watch the PDB.

```bash
kubectl drain "$NODE" --ignore-daemonsets --delete-emptydir-data
kubectl -n lab-upgrade get pods -o wide
kubectl uncordon "$NODE"
```

For the version upgrade, edit `kubernetes_version` in stack 02 to the next minor only. Update addon pins if `docs/VERSIONS.md` lists different builds. Then:

```bash
terraform -chdir=terraform/stacks/02-cluster plan
```

Read the plan. You want a control plane version change and an addon version change, not a new VPC and not a replacement of the access entries. Apply only when that is what the plan says. After the control plane is updated:

```bash
kubectl get nodes
```

The managed group rolls to the AMI that matches the new version because `ami_type` is `AL2023_x86_64_STANDARD` and the group version follows the cluster. Watch `kubectl get nodes` until both are on the new version. `max_unavailable = 1` keeps one old node until the new one is Ready.

## Expected observations

Example only. During drain, one of the lab-upgrade pods moves and one stays, because the PDB wants `minAvailable: 1` and the Deployment has 2 replicas. If both pods were on the drained node, one is evicted and the second eviction waits until the first is Running again. DaemonSets stay, because of `--ignore-daemonsets`.

After a real upgrade, `kubectl version` and `aws eks describe-cluster` agree on the minor you selected.

## Questions

1. Why does the PDB not save you from spot termination?
2. What is the difference between this rolling node group and Karpenter consolidation?
3. Why is 1.34 a poor target in December 2026?

## Spot

Opt-in. In stack 02 set `enable_spot_node_group = true`, plan, and apply. The group is desired 0. Scale it only if you want an instance:

```bash
aws eks update-nodegroup-config --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name spot --scaling-config minSize=0,maxSize=2,desiredSize=1
```

That CLI call drifts from Terraform. The spot group's desired size is fixed at 0 in the stack. The next plan sets it back to 0 and will interrupt the instance. Scale it back to 0 before the next apply.

A pod needs the toleration `awseks.practice/capacity=spot:NoSchedule` or it will not land there. Do not add that toleration to CoreDNS.

## Diagnostics

Upgrade plan wants to replace the cluster: you changed `service_ipv4_cidr`, `ip_family`, or the name. Stop. Drain stuck: a PDB in another namespace has `minAvailable` equal to the replica count, so no pod can leave. `kubectl get pdb -A`. Node group update failed: the new addon is unhealthy. `aws eks describe-addon`.

## Answers

1. Spot interruption is not a voluntary eviction the PDB can delay forever. The instance disappears. The PDB only governs `kubectl drain` and similar API evictions.
2. The managed group replaces instances inside a fixed min and max that you set. Karpenter chooses instances from a NodePool and can add a size you did not name, inside its limits. Lab 15 is that track. This lab does not require it.
3. Standard support for 1.34 ends 2026-12-02. After that the control plane is $0.60 per hour. The default in this repo is 1.35.

## Cleanup

```bash
kubectl delete namespace lab-upgrade
kubectl uncordon "$NODE"
```

Scale the spot group to 0 if you started it. Leave the Kubernetes version where you upgraded it, or plan another upgrade. Do not downgrade. EKS does not support a control plane downgrade.

## Cost

The upgrade itself is the same hourly control plane. A third node during the roll, if `max_size` allows and the group uses it, is an extra t3.medium for the length of the roll. Spot at desired 1 is an instance until you set it back to 0.
