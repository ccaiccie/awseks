# Lab 08 — NetworkPolicy and load balancers

## Objective

See a NetworkPolicy deny, then an internal load balancer, without publishing an admin app.

## Prerequisites

Lab 07. For the controller, [stages/aws-load-balancer-controller/install.sh](../stages/aws-load-balancer-controller/install.sh) with argument `terraform` or `awscli` matching the cluster you built. Class scenes F09–F11 and F16–F17. Chart `3.6.2` is the upstream pin. The EKS user-guide page still shows chart `1.14.0`; the installer refuses to substitute.

## Commands

```bash
kubectl apply -f manifests/base/namespace.yaml
kubectl apply -f manifests/base/config.yaml
kubectl apply -f manifests/base/deployment.yaml
kubectl apply -f manifests/base/service-clusterip.yaml
kubectl apply -f manifests/network/networkpolicy.yaml
kubectl apply -f manifests/network/client-pod.yaml
kubectl rollout status deployment/demo -n lab
```

Apply only one of `manifests/network/ingress-internal-alb-ip.yaml` or `manifests/network/service-internal-nlb-ip.yaml` after the controller is ready. Instance-target files are the comparison, not a second load balancer to leave running.

The class stack uses `class/labs/manifests/alb-ip.yaml` and `nlb-ip.yaml` on `eksclass-cli-*` only, after `06-lbc.sh` and `07-services.sh`.

## Expected observation

With the policy applied, a pod that is not labeled `app=client` does not complete a new connection to the demo pod on TCP 8080. The client pod can. An internal ALB or NLB gets a DNS name in the Ingress or Service status. Target type `ip` registers pod IPs. Target type `instance` registers node IPs and a NodePort. NLB IP targets in the class manifest set client-IP preservation off, so the pod sees the NLB address, not the client, and there is no X-Forwarded-For on that TCP path.

## Question

Does a security group see the same source address as a NetworkPolicy on an ALB IP target?

## Explanation

The pod's socket source is the ALB's private address. X-Forwarded-For is an HTTP header on the ALB path, not the packet source. A NetworkPolicy ipBlock of the laptop will not match that socket.

## Safe failure

Apply the NetworkPolicy before any allow rule and try the client. New connections time out. Delete only `manifests/network/networkpolicy.yaml` to restore. Do not open a NodePort to `0.0.0.0/0`.

## Cost

Each Ingress or LoadBalancer Service is an hourly load balancer until its finalizer finishes. Internal still costs money.

## Cleanup

Delete the Ingress or Service and wait until no load balancer remains tagged `elbv2.k8s.aws/cluster=<your cluster>`. Then uninstall the controller if you are tearing the cluster down. See [docs/cleanup.md](../docs/cleanup.md).
