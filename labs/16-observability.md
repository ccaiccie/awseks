# Lab 16 — Flow logs, the controller, the CNI, and CoreDNS

## Objective

Pick the log stream that matches the failure, and leave dashboards that have no authentication uninstalled.

## Architecture

Four different places:

| Question | Where you look |
| --- | --- |
| Did the packet leave the ENI, and to which address? | VPC flow logs, if you turned them on |
| Did the ALB or NLB controller reject the Ingress? | `kube-system` Deployment `aws-load-balancer-controller` |
| Did the node fail to attach an IP? | `aws-node` DaemonSet logs |
| Did the name resolve? | `coredns` Deployment logs, and the CoreDNS addon events |

Flow logs are CloudWatch ingestion. Stack 01 leaves them off. Enable `enable_flow_logs`, plan, and apply only for this lab. Retention is 1 day. There is no Grafana, no Kubernetes dashboard, and no public Prometheus in this repository. `kubectl logs` and `kubectl top` are the tools.

## Prerequisites

A cluster from stack 02. For the controller section, stack 03. For flow logs, a reviewed apply of stack 01 with `enable_flow_logs = true`.

## Steps

```bash
kubectl -n kube-system logs deploy/coredns --tail=30
kubectl -n kube-system logs daemonset/aws-node --tail=20
kubectl -n kube-system logs deploy/aws-load-balancer-controller --tail=30
```

If flow logs are on:

```bash
aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `eks-lab`) || contains(logGroupName, `vpc`)].logGroupName'
```

The log group name comes from the VPC module. Use the name you see, not a guessed one. In Logs Insights, filter a five minute window. Do not leave the query running all day.

## Expected observations

Example only. CoreDNS logs show `NOERROR` for `kubernetes.default.svc.cluster.local` when lab 04 worked. aws-node logs show IP assignment lines rather than a repeating `Unauthorized`. The controller log shows a reconcile of an Ingress only if lab 09 was applied. With flow logs off, `describe-log-groups` has no group for this VPC. That is the default, not a failure.

## Questions

1. A Service ClusterIP times out and flow logs show no packet to `172.20.0.0/16`. Why is that expected?
2. Targets are unhealthy and flow logs show the ALB ENI sending SYN to the pod IP with no SYN-ACK. Which security group do you open, and which NetworkPolicy?
3. Why is there no dashboard manifest?

## Failure injection

Use lab 06's opt-in DNS policy, or scale CoreDNS to 0 as in lab 04, and read the CoreDNS log and the client error. Put the replicas back.

## Diagnostics

Match the symptom to one stream before you open all of them. An IAM `AccessDenied` in the controller log is not a flow-log problem. A `i/o timeout` on image pull with no flow log to port 443 is the NAT or endpoint path from lab 11.

## Answers

1. The ClusterIP is DNAT'd on the node. The packet on the wire uses the pod IP. Flow logs in the VPC do not show `172.20.0.0/16` as a destination for a normal ClusterIP call.
2. The SYN reached the VPC, so routing worked. The drop is on the way in: the node or pod security group, or an enforced NetworkPolicy. Check the group the ALB controller added, then `kubectl get networkpolicy -A`.
3. A dashboard without authentication is an open API view. This class does not install one. metrics-server is enough for `kubectl top`, and it is not a browser UI.

## Cleanup

Set `enable_flow_logs = false` and apply stack 01 when the lab ends. Delete the log group if the module left it and it is tagged for this project. Confirm in the plan.

## Cost

CloudWatch ingestion is the cost of this lab. A busy NAT gateway makes a noisy log. One day of retention limits the storage, not the ingest fee.
