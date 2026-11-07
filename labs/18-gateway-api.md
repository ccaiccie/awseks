# Lab 18 — Gateway API, only where this controller version documents it

## Objective

Install the CRDs this controller was built against, apply one HTTPRoute, and say what the sample does not configure.

## What is actually documented

Retrieved 2026-11-07:

- AWS Load Balancer Controller chart 3.6.2 is the pin in stack 03.
- The v3.5.0 release notes say the controller requires Gateway API CRDs v1.6.0, and that TCPRoute and UDPRoute are `gateway.networking.k8s.io/v1` in that CRD release. L7 routes use an ALB. L4 routes use an NLB. Mixing them on one Gateway is not supported.
- The controller name for L7 is `gateway.k8s.aws/alb`. The L4 name documented on the ListenerSets page is `gateway.k8s.aws/nlb`.
- The L7 guide still shows some examples as `gateway.networking.k8s.io/v1beta1`, and it attaches a `LoadBalancerConfiguration` (`gateway.k8s.aws/v1`) for the scheme and the certificate. The standard CRD install serves v1.

This repository does not install those CRDs and does not set a feature flag in Helm, because the flag and the CRD channel are controller-specific. Confirm https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/ and the L7 page for 3.6 before you teach the lab. If 3.6 changed the CRD version, follow 3.6, not this paragraph.

`manifests/lab18-gateway/httproute.yaml` uses v1, `gateway.k8s.aws/alb`, and an HTTP listener. It does not include `LoadBalancerConfiguration`. Without that object the controller's default scheme may be internal. Do not guess the fields. Copy the current example from the L7 page if you need internet-facing.

kubeconform does not ship these CRDs. A missing schema in CI is not evidence the API is installed in the cluster.

## Prerequisites

Stack 03 controller Ready. No lab 09 ALB left behind, or you will have two load balancers.

## Steps

```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.0/standard-install.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml
kubectl api-resources | grep gateway
```

The second URL tracks the controller's main branch. For a class, prefer the raw file from the `v3.6.2` tag if it exists, and record the URL you actually applied.

Create a Service the route can use. The sample HTTPRoute expects Service `web` port 80 in `lab-gateway`. Reuse the Deployment from `manifests/lab03-fundamentals/app.yaml` by copying it and changing the namespace, or apply lab 03's file and a second Service. Then:

```bash
kubectl apply -f manifests/lab18-gateway/httproute.yaml
kubectl describe gateway -n lab-gateway web
kubectl describe httproute -n lab-gateway web
```

## Expected observations

Example only, and only after the CRDs match the controller. The GatewayClass is accepted. The Gateway programs an ALB. The hostname may be internal. `Accepted` false with a message about CRD versions means stop and read the controller log rather than editing the API group.

## Questions

1. Why is this lab optional even though the controller chart is installed by default?
2. What is the difference between this HTTPRoute and the Ingress in lab 09?
3. Why does the sample refuse to invent a `LoadBalancerConfiguration`?

## Failure injection

None. A wrong CRD version is enough failure for one lab. Delete the Gateway if an ALB appeared and you do not want it.

## Diagnostics

`kubectl -n kube-system logs deploy/aws-load-balancer-controller`. If the log never mentions the Gateway, the controller build is not reconciling that CRD version. Check `kubectl get crd gateways.gateway.networking.k8s.io`.

## Answers

1. The chart can be installed and still do nothing with Gateway API until the CRDs are present. The default class path uses Ingress and Service, which labs 09 and 10 already cover.
2. Both can end at an ALB with this controller. Ingress is one object. Gateway API splits the class, the listener, and the route so different people can own them. The AWS-specific knobs live in the LBC CRDs, not in the portable HTTPRoute.
3. The field set moved between controller minors, including the storage version of those CRDs (`v1beta1` to `v1` in the 3.5 notes). A guessed spec would apply and then be ignored or rejected.

## Cleanup

```bash
kubectl delete -f manifests/lab18-gateway/httproute.yaml
```

Wait for the ALB to disappear. Leave the CRDs if other people are still using them, or delete the CRDs only when nothing in the cluster references them. Deleting a CRD deletes every object of that kind.

## Cost

An ALB, if the Gateway was accepted, is the same hourly charge as lab 09. An internal ALB still costs money.
