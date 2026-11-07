# Three different decisions

People mix these up because all three can look like "it cannot connect".

## 1. VPC route

The route table of the subnet that contains the ENI decides the next hop for an IP on the wire. `10.0.0.0/16` is local. `0.0.0.0/0` goes to a NAT gateway or is absent. A gateway endpoint for S3 adds a prefix-list route. None of that knows what a Kubernetes Service is.

Private nodes reach the internet only through NAT, or through interface endpoints when you chose `none`. Public subnets reach the internet through the internet gateway. Nodes do not sit in the public subnets.

## 2. Kubernetes Service selection

A Service has a ClusterIP from `172.20.0.0/16`. CoreDNS, running as a Deployment, answers names such as `demo.lab.svc.cluster.local`. kube-proxy programs DNAT on the node from that ClusterIP to an endpoint pod IP. The return packet is matched by conntrack so it is rewritten back to the ClusterIP the client used.

That translation is not a route in the VPC route table. If CoreDNS is down, names fail and IPs can still work. If kube-proxy is down, the ClusterIP does not translate. If the endpoint pod is on another node, the packet after DNAT is an ordinary VPC packet between pod IPs, which is the CNI path in diagram 06, not the Service path in diagram 07.

## 3. IAM

Security groups and NetworkPolicy do not check IAM. A pod that is allowed to open a socket can still get `AccessDenied` from ECR, EC2, or ELB. The node role, the Pod Identity role, and your user are different principals. `kubectl auth can-i` checks Kubernetes RBAC. `aws sts get-caller-identity` checks AWS. An access entry is the bridge for the API server, not for ECR.

## Security group, NACL, NetworkPolicy

- The cluster security group is stateful and attached to control plane ENIs and managed nodes. EKS restores the self-referential rules if you delete them.
- The extra API security group allows TCP 443 from the VPC CIDR to the control plane ENIs only.
- The default network ACL is left in place. A custom deny-all NACL is not applied by these scripts. NACLs are stateless, so a one-way rule breaks return traffic.
- NetworkPolicy enforcement here depends on the VPC CNI agent actually running with network policy enabled. Discover that container from its image or arguments. A fixed container name is not the test, and `--enable-network-policy=false` means the manifest is inert. The AWS considerations page (https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html) says enforcement is aimed at controller-owned pods and that a Service port used with the policy should match the container port.
- The ordinary Service `demo` stays port 80 to container 8080. That is kube-proxy DNAT, not a VPC route. The policy exercise uses Service `demo-policy` on 8080 to container 8080, a direct pod IP on 8080, and a separate destination for egress. Clients are Deployments.

## Load balancers

An internal ALB or NLB is still a billable load balancer. `target-type: ip` registers pod IPs. `target-type: instance` registers node IPs and a NodePort. Instance mode needs the node security group to allow the NodePort from the load balancer. The cluster security group's default "all from self" rule covers node-to-node traffic. It does not by itself describe every load balancer path. Apply one of the sample Services or Ingress objects at a time.

## NAT versus endpoints

| Choice | Egress | Failure | Cost shape |
| --- | --- | --- | --- |
| `single` | One NAT in the first AZ | That AZ's NAT dies and private subnets in every AZ lose the default route | One NAT hour plus data processing |
| `per_az` | NAT in the same AZ as the node | One AZ loses its own egress | One NAT per AZ |
| `none` | No default route | Pulls fail unless `ecr.api`, `ecr.dkr`, and the S3 gateway endpoint all work, and the agent needs `eks-auth` | Interface endpoints per AZ, plus the free S3 gateway |

S3 gateway endpoints do not replace ECR API. ECR API tells the kubelet which layer objects to fetch. Those objects are in S3.
