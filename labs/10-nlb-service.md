# Lab 10 — NLB Service, health, return path, source IP

## Objective

Expose the same style of pod through an NLB in IP mode, then compare instance mode with client IP preservation off.

## Architecture

The return-path figure in [docs/DIAGRAMS.md](../docs/DIAGRAMS.md).

IP target type: client IP preservation is off by default. The node sees the NLB as the source and replies to the NLB's private address. That destination is inside the VPC. The NAT gateway is not used.

Instance target type with preservation on: the node sees the client's public address and routes the reply to `0.0.0.0/0`, which is the NAT gateway. The client never gets that reply through the NLB. The contrast file sets `preserve_client_ip.enabled=false` so the private-subnet nodes have a working return path. The file that would turn preservation on is intentionally not shipped. Turn it on only as a live failure, and turn it off again.

`externalTrafficPolicy` is the kube-proxy half of source IP. `Cluster` may SNAT. `Local` keeps the source and only sends to nodes that have a pod. The IP-mode file leaves the default. The instance file sets `Cluster` and disables preservation so the two mechanisms are not confused.

## Prerequisites

Lab 09's ALB is deleted. Stack 03 controller is Ready.

## Steps

```bash
kubectl apply -f manifests/lab10-nlb/service-ip.yaml
kubectl -n lab-nlb get svc web
ADDR="$(kubectl -n lab-nlb get svc web -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
curl -sS "http://${ADDR}/"
aws elbv2 describe-target-health --target-group-arn "$TG_ARN"
```

Find `TG_ARN` the same way as lab 09, from the load balancer hostname.

## Expected observations

Example only. The Service type is LoadBalancer. The hostname contains `elb`. Target type is `ip`. Health is `healthy` on port 8080. `curl` prints `practice web`. The scheme is internet-facing. Subnets are the public pair.

## Questions

1. Why is the health check HTTP on `/` when the listener is TCP?
2. Where is the source address translated in the default IP-mode NLB?
3. What does `Local` external traffic policy change about which nodes are registered?

## Instance contrast

```bash
kubectl -n lab-nlb delete svc web
# wait until the NLB is gone
kubectl apply -f manifests/lab10-nlb/service-instance-no-preserve.yaml
```

Example only: targets are instances, preservation is false, health becomes healthy, `curl` works. If you flip preservation on, `curl` hangs from the internet and target health may still look healthy, because the health check comes from inside the VPC. That split is the diagnosis.

## Failure injection

Opt-in. Set the annotation `preserve_client_ip.enabled=true` on a copy of the instance Service, apply, curl from outside the VPC, then put `false` back. Do this only after the room has seen the working case.

## Diagnostics

Service stays `<pending>`: controller logs, subnet tags, or an IAM error on the controller role. Healthy targets and a hanging curl: return path, usually preservation plus NAT. Unhealthy targets and a hanging curl: security group or the readiness probe. `kubectl describe svc -n lab-nlb web` shows events from the controller.

## Answers

1. NLB health checks can be HTTP even though the listener does not parse HTTP. The check needs a path the container actually serves.
2. The NLB translates the client source to an NLB address toward the pod. The pod's reply goes to that NLB address. The NLB sends the packet onward to the client.
3. Only nodes with a local pod are used. Pods on other nodes do not receive those flows, and the source is not hidden by kube-proxy SNAT. You still have to get the VPC return path right. `Local` does not fix NLB preservation through a NAT gateway.

## Cleanup

```bash
kubectl delete namespace lab-nlb
```

Wait for the NLB to disappear before stack 03 destroy.

## Cost

An internet-facing NLB is an hourly charge plus NLCUs. Delete it the same day.
