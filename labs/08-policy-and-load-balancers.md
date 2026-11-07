# Lab 08 — NetworkPolicy and load balancers

## Objective

See a NetworkPolicy deny, then an internal load balancer, without publishing an admin app.

## Prerequisites

Lab 07. For the controller, [stages/aws-load-balancer-controller/install.sh](../stages/aws-load-balancer-controller/install.sh) with argument `terraform` or `awscli` matching the cluster you built. Class scenes F09–F11 and F16–F17. Chart `3.6.2` is the upstream pin. The EKS user-guide page still shows chart `1.14.0`; the installer refuses to substitute.

## Commands

Apply the namespace before any namespaced object, and wait until it exists. Then apply the workload. Do not server-dry-run namespaced objects against a namespace that has not been created.

```bash
kubectl apply -f manifests/base/namespace.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/lab --timeout=60s
kubectl apply -f manifests/base/config.yaml
kubectl apply -f manifests/base/deployment.yaml
kubectl apply -f manifests/base/service-clusterip.yaml
kubectl apply -f manifests/network/service-policy.yaml
kubectl apply -f manifests/network/client-deployment.yaml
kubectl apply -f manifests/network/other-deployment.yaml
kubectl rollout status deployment/demo deployment/client deployment/other -n lab
```

Record the baseline before the policy: from the client Deployment, DNS for `demo.lab.svc` succeeds, `demo-policy:8080` succeeds, the demo pod IP on port 8080 succeeds, and the other Deployment's pod IP on port 8080 succeeds. Service `demo` on port 80 is the ordinary DNAT example. It is not the policy assertion.

```bash
kubectl apply -f manifests/network/networkpolicy.yaml
```

After that, keep the four checks separate. DNS from the client still succeeds. A pod from the client Deployment can open the demo pod IP on 8080 and `demo-policy:8080`. A second client labeled something other than `app=client` cannot. The client Deployment's egress to the other Deployment's pod IP on 8080 fails, while a pod that is not selected by `client-egress` can still open that address. That last pair is the egress result. It does not prove the ingress result.

The class stack does the same split in `class/labs/scripts/15-client-tests.sh` with Deployments, not bare Pods. `class/labs/scripts/12-policy.sh` discovers the agent container and waits for PolicyEndpoint objects.

Apply only one of `manifests/network/ingress-internal-alb-ip.yaml` or `manifests/network/service-internal-nlb-ip.yaml` after the controller is ready, and only while the policy is not blocking it. Instance-target files are the comparison, not a second load balancer to leave running. The class manifests `class/labs/manifests/alb-ip.yaml` and `nlb-ip.yaml` belong on `eksclass-cli-*` only.

## Expected observation

The baseline connections succeed before the policy. After it, the three enforced results differ: DNS works, demo port 8080 is limited to `app=client`, and client egress to `app=other` fails while another pod can still reach `other`. An internal ALB or NLB gets a DNS name in the Ingress or Service status. Target type `ip` registers pod IPs. Target type `instance` registers node IPs and a NodePort. NLB IP targets in the class manifest set client-IP preservation off, so the pod sees the NLB address, not the client, and there is no X-Forwarded-For on that TCP path.

## Question

Does a security group see the same source address as a NetworkPolicy on an ALB IP target?

## Explanation

The pod's socket source is the ALB's private address. X-Forwarded-For is an HTTP header on the ALB path, not the packet source. A NetworkPolicy ipBlock of the laptop will not match that socket.

## Safe failure

Run the client and other Deployments before `networkpolicy.yaml`. other-dest must answer. If it does not, stop. A later timeout is not enforcement. After the policy, a fresh connection from the client Deployment to other-dest times out while DNS still works. Delete `manifests/network/networkpolicy.yaml` to restore. Do not open a NodePort to `0.0.0.0/0`.

## Cost

Each Ingress or LoadBalancer Service is an hourly load balancer until its finalizer finishes. Internal still costs money.

## Cleanup

Delete the Ingress or Service and wait until no load balancer remains tagged `elbv2.k8s.aws/cluster=<your cluster>`. Then uninstall the controller if you are tearing the cluster down. See [docs/cleanup.md](../docs/cleanup.md).
