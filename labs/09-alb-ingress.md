# Lab 09 — ALB Ingress, IP mode, then instance mode

## Objective

Publish the example app through an ALB in IP target mode, read the target health, and contrast instance mode without leaving both Ingresses in place.

## Architecture

Forward path: client, IGW, ALB ENI in a public subnet, then the target. In IP mode the target is the pod IP. The return path is pod to ALB ENI, which is inside the VPC, then the ALB sends the client response. NAT is not on that return path.

In instance mode the target is the node, on a NodePort. kube-proxy DNATs to the pod. That DNAT is the kube-proxy figure, not the VPC figure.

The controller's IAM role is Pod Identity from stack 03. Your laptop does not need `elasticloadbalancing:CreateLoadBalancer`.

## Prerequisites

Stack 03 applied and the controller Deployment is Ready:

```bash
kubectl -n kube-system rollout status deploy/aws-load-balancer-controller
```

Delete lab 10's Service first if it exists. One internet-facing load balancer at a time keeps the bill and the diagnosis clear.

## Steps

```bash
kubectl apply -f manifests/lab09-alb/ingress-ip.yaml
kubectl -n lab-ingress get ingress web
kubectl -n lab-ingress describe ingress web
```

Wait until the address is a hostname. Then:

```bash
ADDR="$(kubectl -n lab-ingress get ingress web -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
curl -sS "http://${ADDR}/"
aws elbv2 describe-load-balancers --query "LoadBalancers[?DNSName=='${ADDR}'].LoadBalancerArn" --output text
# Use that ARN as LB_ARN
aws elbv2 describe-target-groups --load-balancer-arn "$LB_ARN" \
  --query 'TargetGroups[].{Type:TargetType,Port:Port,Health:HealthCheckPath}'
aws elbv2 describe-target-health --target-group-arn "$TG_ARN"
```

`describe-target-health` needs the target group ARN from the previous call.

## Expected observations

Example only. `TargetType` is `ip`. Targets are pod IPs from the VPC, port 8080, state `healthy`. `curl` prints `practice web`. The load balancer subnets are the public ones. The security group on the node or the pod ENI allows the ALB's security group on the health-check port. The controller added that rule.

## Questions

1. What does the pod see as the source address of the request?
2. Why is the health check path `/` and the probe port the traffic port?
3. What breaks if the pods are not Ready?

## Instance contrast

Delete the IP Ingress and wait until `describe-load-balancers` no longer shows it. Then:

```bash
kubectl delete -f manifests/lab09-alb/ingress-ip.yaml
# wait for the ALB to disappear, then apply the deployment again without the IP ingress
kubectl apply -f manifests/lab09-alb/ingress-ip.yaml
kubectl delete -n lab-ingress ingress web
kubectl apply -f manifests/lab09-alb/ingress-instance.yaml
```

The second file only contains the Ingress. The namespace and Deployment from the first file must still exist. If you deleted everything, apply `ingress-ip.yaml` and then delete only the Ingress before applying `ingress-instance.yaml`.

Example only: `TargetType` is `instance`. Targets are instance ids, not pod IPs. The port is a NodePort. `curl` still returns the page when health is `healthy`.

Do not apply both Ingress files at once. They share the name `web`.

## Failure injection

Optional. Scale the deployment to 0.

```bash
kubectl -n lab-ingress scale deploy/web --replicas=0
```

Target health becomes `unused` or the group goes empty, and `curl` fails. Scale back to 2.

## Diagnostics

Ingress address stays empty: `kubectl -n kube-system logs deploy/aws-load-balancer-controller`. A subnet error means the `kubernetes.io/role/elb` tag is missing. `AccessDenied` in those logs is the controller role, not your user. Targets `unhealthy` with a 404 means the health path does not match the server. Connection timeout on the health check is a security group between the ALB and the target.

## Answers

1. In IP mode the pod sees the ALB's private address as the source, unless you also enable Proxy Protocol or read `X-Forwarded-For`. The client address is in `X-Forwarded-For` because the ALB is a proxy. This is not the NLB preservation behavior in lab 10.
2. The example server returns 200 on `/`. The traffic port is 8080, which is also the readiness probe. A health check on port 80 would miss the container.
3. The target group has nothing healthy to send to. The ALB still exists and still costs money.

## Cleanup

```bash
kubectl delete namespace lab-ingress
kubectl get ingress -A
```

Wait until the ALB is gone in `describe-load-balancers` before lab 10 or before you destroy the controller.

## Cost

An internet-facing ALB is an hourly charge plus LCUs while it exists. Delete the namespace when the discussion is over. See `docs/COST.md`.
