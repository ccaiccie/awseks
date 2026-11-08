# Ask for the exact reads, not blanket administrator rights

STS GetCallerIdentity identifies the principal; it does not prove other permissions. Actual reads are the safest test of those read actions. No create-operation tests are performed. An administrator may optionally simulate specific actions using an IAM role ARN, not an assumed-role STS ARN; simulation is not complete real-world authorization proof.

| Lesson operations | IAM actions to discuss with administrator |
|---|---|
| AZs/type offerings/type limits | ec2:DescribeAvailabilityZones, ec2:DescribeInstanceTypeOfferings, ec2:DescribeInstanceTypes |
| Existing network reads | ec2:DescribeVpcs, ec2:DescribeVpcAttribute, ec2:DescribeSubnets, ec2:DescribeNetworkInterfaces, ec2:DescribeRouteTables, ec2:DescribeNatGateways, ec2:DescribeInternetGateways, ec2:DescribeSecurityGroups, ec2:DescribeNetworkAcls |
| Potential cost inventory | eks:ListClusters, ec2:DescribeAddresses, ec2:DescribeVolumes |
| Version/add-on compatibility | eks:DescribeClusterVersions, eks:DescribeAddonVersions |
| Optional existing ALB | elasticloadbalancing:DescribeLoadBalancers, elasticloadbalancing:DescribeListeners, elasticloadbalancing:DescribeRules, elasticloadbalancing:DescribeTargetGroups, elasticloadbalancing:DescribeTargetHealth |
| Optional existing cluster | eks:DescribeCluster, eks:ListAddons, eks:DescribeAddon |
| Optional budget reads | budgets:ViewBudget |
| Optional budget create/delete | budgets:ModifyBudget (separately approved only) |
| Optional IAM simulation | iam:SimulatePrincipalPolicy (separate administrator diagnostic) |
| Console temporary login | SignInLocalDevelopmentAccess managed policy prerequisite, plus console access |

Some list/describe actions require Resource="*" because they do not support resource-level scope; others support specific ARNs/conditions. Administrator should construct least-privilege policies with current service authorization references, Region conditions where supported and correct partition/account. This table is not a universal attachable policy and deliberately grants nothing. DescribeVpcAttribute is used for the DNS checks in NETWORK-VERIFY.md.

Read successes do not test Unit 6B create/trust/iam:PassRole permissions. SCPs define a ceiling, not grants; member-account root and delegated administrators remain restricted. Management-account principals are not restricted by SCPs, and service-linked roles are exempt. Identity policies, boundaries, session policies, resource policies and condition context also matter. Do not switch to root or remove organizational protections to “fix” a denial.

Private read ledger: for each attempted API, record action, account, Region, result/time and request ID on error. Redact it before sharing; absence of permission is not absence of resources. Only your administrator can decide the correct remedy.

## Optional C4 tagged budget path — exact IAM/API distinction
CLI create-budget and delete-budget map to IAM `budgets:ModifyBudget`; read budget/notification/subscriber operations map to `budgets:ViewBudget`. Creating this example WITH tags additionally requires `budgets:TagResource`. Its original-generation read requires `budgets:ListTagsForResource`. Do not invent `budgets:CreateBudget`/`budgets:DeleteBudget` IAM actions from API command names. Ask the account administrator for a deliberately scoped approved budget/account policy and applicable billing prerequisites; do not grant yourself broad billing access. No budget ACTION or iam:PassRole is used. The commercial budget ARN has an EMPTY Region component: `arn:aws:budgets::ACCOUNT:budget/NAME`, even though these CLI calls use the us-east-1 service endpoint. Never use that illustrative ACCOUNT/NAME literally.
Official current mapping and ARN: https://docs.aws.amazon.com/service-authorization/latest/reference/list_budgets.html . Retrieved Nov8 2026.
