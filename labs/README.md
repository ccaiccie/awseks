# Labs

Work in order. Later labs say when they are optional. Every lab uses the same cluster. Do not create a second one.

| Lab | You will see | Needs |
| --- | --- | --- |
| [00 Orientation](00-orientation.md) | the two tracks and the bill | nothing applied yet |
| [01 VPC and routing](01-vpc-and-routing.md) | one NAT, two private subnets, the S3 route | stack 01 |
| [02 API access](02-cluster-access.md) | private API, access entries, nodes Ready | stack 02 |
| [03 Pods, probes, config](03-pods-deploy-probes.md) | a non-root Deployment | kubectl |
| [04 DNS and ClusterIP](04-dns-and-service-cidr.md) | CoreDNS versus a routed pod IP | lab 03 |
| [05 VPC CNI](05-vpc-cni.md) | same-node and cross-node pod IPs | two nodes |
| [06 NetworkPolicy and security groups](06-networkpolicy-vs-sg.md) | a policy that does nothing until the agent is on | stack 02 flag |
| [07 API, IAM, RBAC](07-api-iam-rbac.md) | a 403 from the wrong gate | stack 02 |
| [08 Pod Identity and IRSA](08-pod-identity-irsa.md) | two roles, two answers from STS | stack 03 |
| [09 ALB Ingress](09-alb-ingress.md) | IP targets, then the instance contrast | stack 03 |
| [10 NLB Service](10-nlb-service.md) | health, return path, source IP | stack 03, lab 09 deleted |
| [11 Private AWS endpoints](11-private-endpoints.md) | NAT versus ECR and S3 | optional endpoints |
| [12 TLS](12-tls-acm.md) | ACM on a domain you own | optional |
| [13 Storage](13-storage.md) | EBS in one AZ, EFS if you pay | EBS addon |
| [14 HPA](14-hpa.md) | requests, limits, metrics-server | stack 03 |
| [15 Karpenter](15-karpenter.md) | a separate scaler | optional stack 04 |
| [16 Observability](16-observability.md) | flow logs and the four log streams | optional flow logs |
| [17 Upgrades, drain, spot](17-upgrades-pdb-spot.md) | PDB, rolling, spot | lab node group |
| [18 Gateway API](18-gateway-api.md) | what this controller version actually implements | optional CRDs |
| [19 Teardown](19-teardown.md) | finalizers, then Terraform | all of the above |

Expected command output in the labs is an example of the shape of a healthy result. Your addon pod names, IPs, and timestamps will differ.

Answers are at the bottom of each lab. Do the questions first.
