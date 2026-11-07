# Lab 04 — CoreDNS, ClusterIP, and pod IPs

## Objective

Resolve a Service name, compare that address with a pod IP, and say which one the VPC can route.

## Architecture

The kube-proxy figure in [docs/DIAGRAMS.md](../docs/DIAGRAMS.md). CoreDNS pods are themselves pods with VPC addresses. The ClusterIP they answer for is not.

## Prerequisites

Labs 02 and 03. Stack 02 set `service_ipv4_cidr` to `172.20.0.0/16` unless you changed it. The VPC is `10.0.0.0/16`.

## Steps

```bash
kubectl apply -f manifests/lab04-dns/queries.yaml
kubectl -n kube-system get deploy coredns -o wide
kubectl -n lab-fundamentals get svc web -o wide
kubectl -n lab-fundamentals get pods -o wide
kubectl -n lab-dns exec dns-client -- getent hosts web.lab-fundamentals.svc.cluster.local
kubectl -n lab-dns exec dns-client -- getent hosts kubernetes.default.svc.cluster.local
kubectl cluster-info dump | head -n 1 >/dev/null
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIP}{"\n"}'
aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.kubernetesNetworkConfig.serviceIpv4Cidr' --output text
```

The `dns-client` image is the same nginx image, with `command: ["sleep","3600"]`. `getent` is in that image. If your digest's image does not include `getent`, use `wget -qO- http://web.lab-fundamentals.svc.cluster.local` and read the address from `kubectl get svc`.

## Expected observations

Example only.

```text
10.0.12.40
172.20.82.15
172.20.0.1
```

The first address is a pod IP inside `10.0.0.0/16`. The Service and `kubernetes.default` are inside `172.20.0.0/16`. `describe-cluster` prints `172.20.0.0/16`. There is no VPC route for `172.20.0.0/16`.

## Questions

1. A packet from pod A to the ClusterIP is rewritten. Where, and to what destination?
2. Why must the service CIDR and the VPC CIDR not overlap?
3. CoreDNS is a Deployment of two pods. What VPC behavior do you depend on for a pod in AZ b to reach a CoreDNS pod in AZ a?

## Failure injection

Optional and easy to reverse. Scale CoreDNS to 0, try the `getent` again, then scale it back to 2. Do not delete the Deployment. The EKS addon will also try to restore the replica count on the next reconcile.

```bash
kubectl -n kube-system scale deploy/coredns --replicas=0
kubectl -n kube-system scale deploy/coredns --replicas=2
```

## Diagnostics

`getent` returns nothing while CoreDNS is at 0. A response from an address in `10.0.0.0/16` means you resolved a headless service or you looked at a pod IP, not the ClusterIP. Check `.spec.clusterIP`.

## Answers

1. kube-proxy on the source node DNATs the ClusterIP to an endpoint from the EndpointSlice. The destination after DNAT is the selected pod's VPC IP. The drawing for that selection is separate from the VPC route drawing.
2. The VPC would try to route the service range, or the CNI would try to assign it. The guard in stack 02 refuses the overlap at plan time.
3. The pod IP in the other subnet is a normal VPC destination. The route is the local VPC route, not the NAT gateway. Security groups on the nodes must allow that traffic. The module's recommended node rules do.

## Cleanup

`kubectl delete -f manifests/lab04-dns/queries.yaml` when you are finished with DNS. Leave lab 03 if you still want the Service.

## Cost

No new AWS resources.
