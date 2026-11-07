# Permission planning — no administrator wildcard shortcut

These scripts intentionally DO NOT attach AdministratorAccess to any role or write an admin-wide provisioning policy. Provisioning IAM permissions depend on organizational SCPs/boundaries/tag conditions and should be granted by a sandbox administrator for the exact resources. Having EKS ClusterAdminPolicy does not grant IAM/EC2 APIs. The bootstrap operator role must also permit assuming ADMIN_ROLE_ARN or kubeconfig must deliberately use existing credentials without a second assume.

## Provisioning action families to review
|Stage|Actions required (scope to stack ARNs/tags where each AWS action supports it)|
|---|---|
|Preflight|sts:GetCallerIdentity; eks:DescribeClusterVersions, DescribeAddonVersions, DescribeAddonConfiguration; ec2:DescribeAvailabilityZones, DescribeInstanceTypeOfferings and describe network resources; servicequotas:ListServiceQuotas|
|Network|ec2:CreateVpc/ModifyVpcAttribute/CreateTags; CreateSubnet/ModifySubnetAttribute; CreateInternetGateway/AttachInternetGateway; CreateRouteTable/CreateRoute/AssociateRouteTable; AllocateAddress/CreateNatGateway; corresponding exact cleanup Delete/Detach/Disassociate/Release actions; Describe* needed by guards|
|IAM|iam:CreateRole/GetRole/TagRole/AttachRolePolicy/PutRolePolicy/DetachRolePolicy/DeleteRolePolicy/DeleteRole/ListAttachedRolePolicies/ListRolePolicies; CreatePolicy/DeletePolicy; inspect organizations' permission-boundary requirements before attempting|
|EKS|eks:CreateCluster/DescribeCluster/UpdateClusterConfig/DeleteCluster/CreateNodegroup/DescribeNodegroup/DeleteNodegroup; CreateAddon/DescribeAddon/DeleteAddon/DescribeAddonVersions; CreateAccessEntry/AssociateAccessPolicy; CreatePodIdentityAssociation/DeletePodIdentityAssociation/ListPodIdentityAssociations/DescribeUpdate; TagResource as used|
|Nodes/endpoints|ec2:CreateLaunchTemplate/DeleteLaunchTemplate; CreateVpcEndpoint/DeleteVpcEndpoints; CreateSecurityGroup/AuthorizeSecurityGroupIngress/RevokeSecurityGroupIngress/DeleteSecurityGroup; relevant describe calls|
|Observability/LB diagnostics|logs:DescribeLogGroups; optional exact group PutRetentionPolicy/DeleteLogGroup; elasticloadbalancing:DescribeLoadBalancers/DescribeTargetGroups/DescribeTargetHealth/DescribeTags (no manual LB deletion required in primary path)|
|First-use service-linked roles|Some sandbox accounts need iam:CreateServiceLinkedRole, condition-limited to eks.amazonaws.com, eks-nodegroup.amazonaws.com, elasticloadbalancing.amazonaws.com, autoscaling.amazonaws.com as appropriate. Do not grant unconstrained service-linked-role creation casually. Existing account roles may make this unnecessary.|

Read-only AWS APIs frequently require Resource `*`; that is different from `Action:*`. Tag/resource conditions are API-specific: a single magic tag condition across ALL EC2 create/read APIs often denies necessary calls. Use IAM Access Analyzer/policy simulation and documented service authorization actions; test in sandbox. This action inventory is not a claimed complete production IAM policy.

Example **PassRole boundary fragment**, replace exact account/region/stack names and integrate with the approved provisioning policy (not a full standalone grant):
```json
{"Version":"2012-10-17","Statement":[
 {"Effect":"Allow","Action":"iam:PassRole","Resource":"arn:aws:iam::ACCOUNT:role/STACK-cluster","Condition":{"StringEquals":{"iam:PassedToService":"eks.amazonaws.com"}}},
 {"Effect":"Allow","Action":"iam:PassRole","Resource":"arn:aws:iam::ACCOUNT:role/STACK-node","Condition":{"StringEquals":{"iam:PassedToService":"ec2.amazonaws.com"}}},
 {"Effect":"Allow","Action":"iam:PassRole","Resource":["arn:aws:iam::ACCOUNT:role/STACK-cni","arn:aws:iam::ACCOUNT:role/STACK-lbc","arn:aws:iam::ACCOUNT:role/STACK-ebs","arn:aws:iam::ACCOUNT:role/STACK-reader"],"Condition":{"StringEquals":{"iam:PassedToService":"pods.eks.amazonaws.com"}}}
]}
```

IAM and EKS authorization are distinct. The lab's administrator EKS access policy is knowingly cluster-wide bootstrap authorization for one role in a disposable cluster; a namespace viewer exercise uses a different role/access entry and custom RBAC, never reuses admin principal and claims it is denied. Managed policies for nodes/CNI/CSI/controller are AWS/upstream-maintained baselines, NOT mathematically minimized custom permissions; production should review restrictions. Controller runtime policy is downloaded from exact v3.6.2 public release and hashed for local review, not silently given to nodes.
