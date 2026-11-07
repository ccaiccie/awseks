# Lab operator IAM

Create these yourself before `terraform apply`. Terraform does not create the human.

1. Render the policy. The script substitutes your account, Region, and cluster name. It does not call AWS.

   ```bash
   export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
   export AWS_REGION=us-west-2
   export CLUSTER_NAME=eks-lab
   ./scripts/render-operator-policy.sh > /tmp/lab-operator.json
   ```

2. Read `/tmp/lab-operator.json`. It allows the EC2, EKS, IAM, KMS, S3, log, and EFS actions the stacks use. EC2 mutations are limited to the selected Region. IAM role changes are limited to path `/awseks-practice/`. `iam:PassRole` is only those roles, and only to `eks.amazonaws.com`, `ec2.amazonaws.com`, and `pods.eks.amazonaws.com`.

3. Create a permissions boundary from `permissions-boundary.json`. It denies account and purchase APIs, and it denies attaching `AdministratorAccess`, `IAMFullAccess`, `PowerUserAccess`, and `NetworkAdministrator`.

4. Attach the rendered policy to the user or role you will use, with that boundary. Put that principal's ARN in `admin_principal_arns` for stack 02. Do not use the account root.

`sts:GetCallerIdentity` is in the policy so the explicit allow is visible. IAM evaluates it even when the action is allowed by default for a signed caller.

The EC2 statement uses `Resource: "*"` because CreateVpc and CreateSubnet do not accept a resource ARN for a resource that does not exist yet. The boundary and the Region condition are the scope. If a call returns `AccessDenied`, add that action to a reviewed statement. Do not replace this policy with an admin policy.

EKS resource ARNs for addons, access entries, and pod identity associations follow the shapes in the policy. If `CreateCluster` fails on resource scoping, the separate `CreatePracticeCluster` statement allows `eks:CreateCluster` on `*`. Narrow it after the first successful create if your account's CloudTrail shows a stable ARN.

Service-linked roles for EKS and ELB are outside `/awseks-practice/`. The policy allows `iam:CreateServiceLinkedRole` only for `eks.amazonaws.com`, `eks-nodegroup.amazonaws.com`, and `elasticloadbalancing.amazonaws.com`.
