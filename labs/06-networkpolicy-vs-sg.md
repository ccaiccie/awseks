# Lab 06 — NetworkPolicy versus security groups

## Objective

Show that a NetworkPolicy object is stored even when nothing enforces it, and that a security group is a different checkpoint on the ENI.

## Architecture

NetworkPolicy is evaluated by the VPC CNI network policy agent on the node, after you set `enable_network_policy = true` and apply stack 02. A security group is evaluated by the hypervisor on the ENI, before the packet is a pod concern. kube-proxy's allow or DNAT decision is a third step and is not either of those.

The VPC CNI also has a `SecurityGroupPolicy` CRD (`vpcresources.k8s.aws`). That CRD attaches extra security groups to a pod ENI. It is not a Kubernetes NetworkPolicy. Confirm the CRD with `kubectl explain securitygrouppolicy` before you use it. This lab does not ship a manifest for it, because the group id would be an account-specific value and the CRD is easy to confuse with NetworkPolicy.

## Prerequisites

Lab 02. For enforcement, set `enable_network_policy = true` in stack 02, plan, and apply. The addon configuration is `enableNetworkPolicy: "true"`. Until you do that, the policy object exists and does not filter traffic. That difference is the point.

## Steps

```bash
kubectl apply -f manifests/lab06-netpol/policy.yaml
kubectl -n lab-netpol rollout status deploy/web
kubectl -n kube-system get ds aws-node -o yaml | grep -n enableNetworkPolicy || true
kubectl -n lab-netpol exec deploy/web -- wget -qO- --timeout=3 http://web.lab-netpol.svc.cluster.local || true
```

From a pod in another namespace, for example `lab-fundamentals` if it is still up:

```bash
kubectl -n lab-fundamentals exec deploy/web -- wget -qO- --timeout=3 http://web.lab-netpol.svc.cluster.local || true
```

## Expected observations

Example only.

With the agent off, both wgets return `practice web` or the default nginx page, because nothing enforces the policy. `grep` finds no `enableNetworkPolicy` in the live DaemonSet.

With the agent on, the same-namespace wget still works. The other namespace times out or is reset. CoreDNS still answers, because the policy allows UDP/TCP 53 to `kube-system`.

Security groups did not change. `aws ec2 describe-security-groups` for the node group still shows the rules Terraform created.

## Questions

1. Why can a NetworkPolicy allow traffic that a security group still drops?
2. The policy allows egress only to kube-system on port 53. What breaks, and what does not, for a pod that also calls the AWS API?
3. Is the node security group's egress `0.0.0.0/0` the same decision as the API endpoint allowlist?

## Failure injection

Opt-in, and only after the enforcing agent is on.

```bash
kubectl apply -f manifests/lab06-netpol/deny-dns-opt-in.yaml
```

DNS lookups from the web pod start failing. Egress rules from every policy are combined as a union only when they select the pod... actually a deny-all egress policy unions with the allow policy. An empty egress list does not subtract the other policy's allow. Read the result before you tell the room it is a deny.

If DNS still works, that is the lesson: NetworkPolicy is allow-list additive across policies. To block DNS you remove the allow, you do not add an empty policy. Delete the opt-in object either way:

```bash
kubectl delete -f manifests/lab06-netpol/deny-dns-opt-in.yaml
```

## Diagnostics

`kubectl describe networkpolicy -n lab-netpol`. If the agent is on and cross-namespace still works, the pod labels do not match `app.kubernetes.io/name=web`. If the agent pods restarted and the node shows `NetworkPolicy` events, describe the aws-node pod.

## Answers

1. The security group drops the packet on the ENI. The CNI never sees it, so the NetworkPolicy is not consulted. The reverse is also true: a wide security group still loses to an enforced NetworkPolicy.
2. DNS still works. Calls to the public AWS API follow the default route to NAT, and this policy does not allow that egress, so they fail when the agent is on. Pod Identity's link-local address is node-local and is not this egress rule. Test it rather than assuming the link-local path is covered.
3. No. Node egress to `0.0.0.0/0` is how private nodes reach the internet through NAT. The API allowlist is who may open a TLS session to the EKS endpoint. The guardrail rejects a world-open API. It does not remove NAT.

## Cleanup

`kubectl delete -f manifests/lab06-netpol/policy.yaml`. Leave `enable_network_policy` as you want it for the rest of the day. Turning it off is another reviewed apply.

## Cost

The network policy agent uses some CPU and memory on each node. No new AWS bill line beyond that.
