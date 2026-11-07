#!/usr/bin/env bash
# Print the teardown order. This script never deletes resources.
set -euo pipefail

cat <<'EOF'
Teardown order for one practice environment. Run the commands yourself.
This script does not call terraform destroy or kubectl delete.

1. Delete student workloads and wait until namespaces are gone:
     CONFIRM=delete-lab-workloads CLUSTER_NAME=<name> ./scripts/delete-lab-workloads.sh
   If a namespace sticks, a Service type LoadBalancer or a PVC finalizer is
   waiting on AWS. Delete that Service or PVC and wait. Do not remove
   finalizers by hand unless you have already deleted the AWS object.

2. Optional stack 04, only if you enabled it:
     terraform -chdir=terraform/stacks/04-karpenter destroy
   Review the plan. It should list only Karpenter roles, the queue, and the chart.

3. Stack 03:
     terraform -chdir=terraform/stacks/03-platform destroy
   This removes the load balancer controller, metrics-server, the identity
   demo bucket, and EFS if you opted in. Load balancers should already be gone.

4. Stack 02:
     terraform -chdir=terraform/stacks/02-cluster destroy
   Nodes drain as the node group deletes. The cluster role, KMS key (7 day
   window), OIDC provider, and addons go with it. If deletion protection is
   true, set cluster_deletion_protection=false, apply, then destroy.

5. Stack 01:
     terraform -chdir=terraform/stacks/01-network destroy
   NAT gateways, EIPs, and interface endpoints are the resources that keep
   billing after the cluster is gone. Confirm they are in the destroy plan.

6. Residual charges:
     aws ce get-cost-and-usage is account-wide. Prefer a filtered console view
     for the Project=awseks-practice tag, then look for leftover NAT, EIP,
     ELB, EBS, and EFS in this Region:
       aws ec2 describe-nat-gateways --filter Name=tag:Project,Values=awseks-practice
       aws ec2 describe-addresses --filters Name=tag:Project,Values=awseks-practice
       aws elb describe-load-balancers
       aws elbv2 describe-load-balancers
       aws ec2 describe-volumes --filters Name=tag:Project,Values=awseks-practice Name=status,Values=available
   Do not delete untagged account resources from these commands. Tagged
   leftovers are in scope. Untagged ones need a human to decide.

7. KMS keys scheduled for deletion still exist until the 7 day window ends.
   They cost about one dollar per month until AWS deletes them.
EOF
