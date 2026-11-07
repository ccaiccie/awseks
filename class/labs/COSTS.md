# COST WARNING — read BEFORE any create command

This is a BILLABLE sandbox, not an AWS Free Tier promise. No resources were launched while preparing this package. COST_ACK is an operator acknowledgement, not an automatic spend cap. AWS Budgets alerts do not atomically stop charges. Obtain account-owner approval before running it.

Primary topology: one Standard EKS cluster, two on-demand m6i.large nodes (30GiB encrypted gp3 roots each), TWO NAT gateways and EIPs, 2 AZs, control-plane logs; optional ALB + NLB, 4GiB gp3 disk, six interface endpoint services × two AZs, S3 gateway endpoint, metrics server. Endpoint extension intentionally leaves NAT in place; it costs MORE until a separate measured redesign removes NAT dependencies.

Use current regional calculator/pricing before launch (S47 https://aws.amazon.com/eks/pricing/; https://calculator.aws/). A rough formula, NOT a quoted price:

`hours × (EKS standard cluster-hour + 2×EC2 instance-hour + 2×NAT-hour + 2×public-IPv4-hour + optional LB-hour + optional 12×endpoint-ENI-hour) + NAT GB + LB LCU/NLCU + endpoint GB + gp3 GiB-month/IOPS + CloudWatch ingest/storage + data transfer + DNS/domain costs`.

Public IPv4 billing, extended-support rates, regional differences and discounts can materially change this. EKS extended support costs extra; scripts select standard support and set supportType=STANDARD (which permits automatic control-plane upgrades at end of standard support; plan upgrades rather than relying on them). A stopped laptop or deleted kubeconfig stops NOTHING in AWS. Reducing nodes to zero does not stop cluster/NAT/LB/storage billing. Managed nodegroup minSize=2 deliberately supports HA teaching.

Two NATs avoid a dependency on one AZ's NAT and avoid routing all other-AZ egress over an AZ boundary. Single-NAT alternative saves a gateway-hour/EIP but adds AZ dependency and potential cross-AZ charges; if explicitly adopting, change private B default to NAT A and adjust teardown. Do not label that alternative highly available. NAT-free isolated variant requires inventory of every AWS/public dependency and carefully configured endpoints/mirrors, not merely deleting the NAT.

Cost guard: set a sandbox budget/alert before use in the organization's normal approved process; choose a scheduled manual end time; run cleanup while controller/node resources still work; inspect EC2/NAT/ELB/EBS/EFS/endpoints/logs/snapshots afterward. Budget creation is not executed by this bundle. Keep raw billing/identity info private.
