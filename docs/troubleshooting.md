# Troubleshooting

Checkpoints are lines in `cli/state/checkpoints.log` and the Terraform resource that is still creating. Match the symptom, then use one remedy. Do not delete the VPC while the cluster still exists.

| Checkpoint or symptom | What you see | Remedy |
| --- | --- | --- |
| Preflight cannot call `describe-addon-versions` | `AccessDeniedException` or an empty version | The caller needs `eks:DescribeAddonVersions`. Fix IAM before any create call. Region must offer the minor. |
| `create-cluster` says the role cannot be assumed | `InvalidParameterException` about the cluster role, then success on a later attempt | IAM is eventually consistent. `30-cluster.sh` retries six times. If it still fails, the role trust is not `eks.amazonaws.com` or `iam:PassRole` is missing. See [iam.md](iam.md). |
| Cluster stays `CREATING` past 20 minutes | `aws eks describe-cluster` shows `CREATING` or `CREATE_FAILED` | Read `health` and the status message. Subnets must be in at least two AZs and large enough for control plane ENIs. Do not start a second cluster with the same name. |
| Node group times out and nodes are `NotReady` | `aws-node` is missing or `CrashLoopBackOff` | vpc-cni was not created, or it was created only after the node group waiter. Re-run in the script order: early add-ons, then node group, then wait. Confirm the node role has `AmazonEKS_CNI_Policy` on the first apply. |
| Add-on `CREATE_FAILED` with a version error | `Addon version specified is not supported` | The pin is stale. Run `describe-addon-versions` and update `docs/versions.md` and `terraform/locals.tf` together. Do not guess an eksbuild. |
| `coredns` pending | Pods `Pending` and nodes `Ready` | Usually scheduling. Two nodes and the default requests should fit. `kubectl describe pod -n kube-system -l k8s-app=kube-dns`. |
| EBS PVC stays `Pending` | `UnauthorizedOperation` or no provisioner | Pod Identity agent not Ready, or the association service account is not `ebs-csi-controller-sa`. `kubectl describe pvc -n lab`. |
| `kubectl` timeout | TCP to the API fails | Public endpoint is off, or your IP is not in `public_access_cidrs`. Private endpoint works from inside the VPC. `aws eks describe-cluster --query cluster.resourcesVpcConfig`. |
| `kubectl` `Unauthorized` | You reached the API | The caller has no access entry. `aws eks list-access-entries --cluster-name ...`. Authentication mode must be `API`. |
| Image pull `ImagePullBackOff` | nodes cannot reach ECR | NAT route missing, or `none` without `ecr.api`, `ecr.dkr`, and the S3 gateway endpoint. Security group egress on the cluster group must allow 443. |
| Helm chart 3.6.2 not found | install script exits | Do not install `latest`. Upstream chart 3.6.2 was fetched on 2026-11-07. The EKS user-guide page still shows 1.14.0 and is not a reason to float. |
| Controller pods `CrashLoop` and IMDS timeouts | hop limit is 1 | The Helm install sets `region` and `vpcId` so the controller does not need IMDS. Confirm those values. |
| `delete-cluster` `InvalidRequestException` | deletion protection | `aws eks update-cluster-config --name <name> --no-deletion-protection`, wait until ACTIVE, then delete. |
| VPC delete `DependencyViolation` | ENIs still present | Wait for EKS to delete control plane ENIs. List them. Do not detach an ENI whose description you do not recognize. |
| Plan wants to replace the cluster | `version` or CIDR or authentication mode | Those force a new cluster. Read the plan. Do not apply a replace unless you meant to delete the workloads. |

Example of a healthy resources VPC config after create (ids are illustrative):

```json
{
  "endpointPrivateAccess": true,
  "endpointPublicAccess": false,
  "publicAccessCidrs": ["0.0.0.0/0"],
  "subnetIds": ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
}
```

`publicAccessCidrs` can still show `0.0.0.0/0` when the public endpoint is **false**. That is the API default for the field and it does not open the endpoint. When the public endpoint is true, this lab sends only your CIDR. If you see `endpointPublicAccess: true` together with `0.0.0.0/0`, stop and fix the config. The scripts are written to refuse that combination.
