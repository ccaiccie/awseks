# Cleanup

Delete front-door and disk objects before you delete the controller, the nodes, or the VPC. Load balancer and volume finalizers will block namespace and node deletion, and a NAT gateway or public IPv4 left behind keeps billing.

## Order

1. Delete Ingress objects and `Service` type `LoadBalancer` in the lab cluster. Wait until `kubectl describe` no longer shows a finalizer waiting on the load balancer, and until `tag:GetResources` shows no load balancer tagged `elbv2.k8s.aws/cluster=<your cluster>`.
2. Delete PVCs and wait. `gp3` in this lab uses `reclaimPolicy: Delete`. Data on those volumes is gone. If you changed a volume to `Retain`, delete or snapshot it yourself or it keeps billing.
3. Uninstall the Helm release `aws-load-balancer-controller` if you installed it.
4. Delete add-ons, the managed node group, then the cluster. Disable deletion protection first or `DeleteCluster` returns `InvalidRequestException`.
5. Delete only the VPC pieces recorded for this cluster: endpoints, NAT gateways, Elastic IPs, route tables this lab tagged, the internet gateway, subnets, the extra security groups, then the VPC.
6. Delete the IAM roles and the customer-managed controller policy recorded for this cluster. Do not delete AWS managed policies.
7. Look for a log group named `/aws/eks/<cluster>/cluster` if you enabled control plane logs.

## Terraform path

```bash
cd terraform
# 1-3. kubectl/helm against this cluster's kubeconfig only
export KUBECONFIG="$PWD/kubeconfig-awseks-tf-lab"
kubectl config current-context   # must print awseks-tf-lab
kubectl delete ingress --all -A --wait=true --timeout=300s
kubectl delete pvc --all -A --wait=true --timeout=300s
stages/aws-load-balancer-controller/uninstall.sh terraform

# 4. protection is an attribute. Change it and apply before destroy.
# set deletion_protection = false in terraform.tfvars
terraform plan -out=tfplan
terraform apply tfplan
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

`terraform destroy` while `deletion_protection` is still true fails, which is the point. Do not use `-refresh=false` to skip that. The state file is local unless you copied `backend.tf.example` yourself.

## AWS CLI path

`cli/bin/90-cleanup.sh` implements the order above for ids in `cli/state/cluster.env`. It asks you to type `delete awseks-cli-lab`. It checks `Provisioner=awscli` on the cluster, VPC, and roles. It does not call `describe-vpcs` and delete every VPC. If the kubeconfig context is not the CLI cluster, it stops before `kubectl delete`.

## Afterward

```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName'
aws ec2 describe-nat-gateways --filter Name=state,Values=available --query 'NatGateways[].NatGatewayId'
aws ec2 describe-addresses --query 'Addresses[?AssociationId==null].AllocationId'
```

Those reads are account-wide on purpose so you can see leftovers. Do not pipe them into `delete-*` without checking each id. An unassociated Elastic IP is a common leftover after a NAT gateway delete races the address release. Re-run the release for the allocation id stored in the state file only.
