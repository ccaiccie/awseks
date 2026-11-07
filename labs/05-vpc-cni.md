# Lab 05 — VPC CNI, same node, cross node, and IP use

## Objective

Read a pod IP from the subnet, see two pods on different nodes, and account for warm IPs before the subnet is full.

## Architecture

Pod IPs are secondary addresses on the worker ENI, or on an extra ENI the CNI attaches. They are not an overlay. Cross-node traffic is VPC routing of those addresses. Same-node traffic still uses the pod IP, and the CNI programs the host so the packet reaches the other veth.

## Prerequisites

Two Ready nodes from stack 02. Prefix delegation is off. The private subnets are `/19`, so you will not exhaust them by accident. This lab measures warm IPs instead of filling a `/19`.

## Steps

```bash
kubectl apply -f manifests/lab05-cni/spread.yaml
kubectl -n lab-cni rollout status deploy/spread
kubectl -n lab-cni get pods -o wide
kubectl -n kube-system get pods -l k8s-app=aws-node -o wide
kubectl -n kube-system logs daemonset/aws-node --tail=20
```

On each node name from the wide output:

```bash
kubectl describe node "$NODE" | sed -n '/Allocated resources/,+8p'
aws ec2 describe-network-interfaces \
  --filters Name=addresses.private-ip-address,Values="$POD_IP" \
  --query 'NetworkInterfaces[].{Id:NetworkInterfaceId,Subnet:SubnetId,Ips:PrivateIpAddresses[].PrivateIpAddress}'
```

Replace `$POD_IP` with one pod IP from `kubectl get pods -o wide`.

## Expected observations

Example only. The two pods show different `NODE` values because of the topology spread constraint. Both IPs are inside the private CIDRs from stack 01 (`10.0.0.0/19` and `10.0.32.0/19` for the default VPC). `describe-network-interfaces` shows those IPs as secondary addresses on an ENI attached to the instance. The ENI has more addresses than running pods. Those extras are warm.

## Questions

1. What is the difference between a warm IP and a free IP in the subnet?
2. Why does a DaemonSet of the CNI run on every node, including nodes that already have an IP?
3. Which problem is prefix delegation solving, and why is it left off here?

## Failure injection

Optional. This drifts from the Terraform addon until the next addon update, because you are editing a live DaemonSet.

```bash
kubectl -n kube-system set env daemonset/aws-node WARM_IP_TARGET=2 MINIMUM_IP_TARGET=2
```

Watch the ENI again after a minute. Restore by setting the variables back or by re-applying the addon from stack 02, which you should plan and read before you apply.

Do not scale the deployment to hundreds of replicas.

## Diagnostics

Both pods on one node means the spread constraint could not be satisfied or one node is tainted. `kubectl describe pod` shows the scheduling message. An IP outside the VPC CIDR means you are looking at the ClusterIP. A `MaxENI` or insufficient address event in the CNI log is the real exhaustion signal. A `/19` will not produce it in this class.

## Answers

1. A warm IP is already assigned to the ENI and reserved by the CNI so the next pod starts quickly. It is not free for another ENI or another AWS resource in the subnet. The subnet's available count drops by the warm addresses too.
2. Each node has its own ENIs. The agent on that node allocates and frees addresses and programs the routes and policy rules for pods on that host.
3. Prefix delegation gives the node a `/28` at a time so a large node does not hit the ENI and secondary-IP quota as fast. It also makes IP use jump in blocks of 16. The class leaves it off so the secondary-IP list you describe is one address per slot.

## Cleanup

`kubectl delete -f manifests/lab05-cni/spread.yaml`. If you changed `WARM_IP_TARGET`, put it back.

## Cost

A few extra secondary IPv4 addresses. No new instance.
