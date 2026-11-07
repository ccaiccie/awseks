# AWS CLI path

Executable copies of these commands are `cli/bin/*.sh`. This page is the reading copy: flags, order, and example output. Example ids are not from a real account. A line marked `EXAMPLE` is the shape of a successful response, not a transcript from this workspace.

The cluster name must match `^awseks-cli-[a-z0-9-]{1,24}$`. The default is `awseks-cli-lab`. Terraform owns `awseks-tf-*`. The scripts refuse the other prefix.

## 0. Tools, identity, region

`cli/bin/00-preflight.sh` is read-only aside from writing `cli/state/cluster.env` (account id, caller ARN, region, AZ list). It does not print credential environment variables.

```bash
aws --version
kubectl version --client -o json
helm version --short
jq --version
aws sts get-caller-identity --output json
aws configure get region
aws ec2 describe-availability-zones \
  --filters Name=state,Values=available Name=opt-in-status,Values=opt-in-not-required \
  --query 'AvailabilityZones[].ZoneName' --output text
aws eks describe-addon-versions \
  --addon-name vpc-cni \
  --kubernetes-version 1.35 \
  --query 'addons[0].addonVersions[0].addonVersion' \
  --output text
```

EXAMPLE `aws --version`:

```text
aws-cli/2.39.6 Python/3.13.7 Linux/6.12.113 exe/x86_64
```

The docs site revision and your installed CLI can differ. The scripts require the `aws-cli/2.` prefix.

EXAMPLE `get-caller-identity`:

```json
{"UserId": "AIDAEXAMPLE", "Account": "111122223333", "Arn": "arn:aws:iam::111122223333:role/Admin"}
```

Stop if `Account` is not the account you intend to bill.

## 1. Network

`cli/bin/10-network.sh` creates, tags, and records:

1. `aws ec2 create-vpc --cidr-block 10.0.0.0/16`
2. `aws ec2 modify-vpc-attribute --enable-dns-support` and `--enable-dns-hostnames`
3. `aws ec2 create-internet-gateway` and `attach-internet-gateway`
4. Public and private `create-subnet` calls. Public subnets get `--map-public-ip-on-launch Value=true` and tag `kubernetes.io/role/elb=1`. Private subnets get `kubernetes.io/role/internal-elb=1` and no public IPv4 mapping.
5. Public route table, `create-route --destination-cidr-block 0.0.0.0/0 --gateway-id`, associations.
6. `aws ec2 allocate-address --domain vpc`, `create-nat-gateway`, then poll `describe-nat-gateways` until `available`. `per_az` repeats that once per AZ. `none` skips it.
7. Private route tables. `single` and `per_az` add `0.0.0.0/0` via the NAT. `none` does not.
8. Security group `${CLUSTER}-api`: ingress TCP 443 from the VPC CIDR, default `0.0.0.0/0` egress revoked, egress replaced with the VPC CIDR.
9. Security group `${CLUSTER}-endpoints`: ingress TCP 443 from the VPC CIDR.
10. S3 gateway endpoint on the private route tables: `--service-name com.amazonaws.${AWS_REGION}.s3 --vpc-endpoint-type Gateway`.
11. If interface endpoints are on: `ecr.api`, `ecr.dkr`, `eks-auth`, `ec2`, `sts`, `logs`, `elasticloadbalancing`, `autoscaling`, type `Interface`, `--private-dns-enabled`, in the private subnets.

EXAMPLE after the NAT poll: `NatGateways[0].State` is `available`.

Re-running the script reuses ids in `cli/state/cluster.env`. If a tagged VPC exists and the state file does not know it, the script stops. It will not adopt or duplicate it.

## 2. IAM

`cli/bin/20-iam.sh` does not create an instance profile.

| Role | Trust | Policies |
| --- | --- | --- |
| `${CLUSTER}-cluster` | `eks.amazonaws.com` | `AmazonEKSClusterPolicy`, `AmazonEKSVPCResourceController` |
| `${CLUSTER}-node` | `ec2.amazonaws.com` | `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryPullOnly`, `AmazonEKS_CNI_Policy` |
| `${CLUSTER}-ebs-csi` | `pods.eks.amazonaws.com` with namespace and service account conditions | `AmazonEBSCSIDriverPolicyV2` |
| `${CLUSTER}-aws-load-balancer-controller` | same, service account `aws-load-balancer-controller` | customer policy from `policies/aws-load-balancer-controller-v2.14.1.json` |

```bash
aws iam create-role --role-name awseks-cli-lab-cluster \
  --assume-role-policy-document file://cli/state/cluster-trust.json
aws iam attach-role-policy --role-name awseks-cli-lab-cluster \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam get-role --role-name awseks-cli-lab-node --query Role.Arn --output text
```

EXAMPLE role ARN: `arn:aws:iam::111122223333:role/awseks-cli-lab-node`.

You still need `iam:PassRole` on those role ARNs for `eks.amazonaws.com`. The lab does not attach that permission to you. [iam.md](iam.md) explains why create-cluster fails without it.

## 3. Cluster

`cli/bin/30-cluster.sh` writes `cli/state/create-cluster.json` and calls:

```bash
aws eks create-cluster --cli-input-json file://cli/state/create-cluster.json
aws eks wait cluster-active --name awseks-cli-lab
```

The JSON sets:

- `resourcesVpcConfig.subnetIds` to the private subnets
- `endpointPrivateAccess: true`
- `endpointPublicAccess` from your config
- `publicAccessCidrs` only when the public endpoint is true
- `securityGroupIds` to the API security group
- `kubernetesNetworkConfig.ipFamily: ipv4` and `serviceIpv4Cidr: 172.20.0.0/16`
- `accessConfig.authenticationMode: API`
- `accessConfig.bootstrapClusterCreatorAdminPermissions: true`
- `upgradePolicy.supportType: STANDARD`
- `bootstrapSelfManagedAddons: false`
- `deletionProtection: true`
- tags `Project=awseks-practice`, `Provisioner=awscli`

No `computeConfig`, so Auto Mode is not turned on.

EXAMPLE `describe-cluster` query used at the end of `60-access.sh`:

```json
{
  "auth": "API",
  "creatorAdmin": true,
  "private": true,
  "public": false,
  "support": "STANDARD"
}
```

## 4. Early add-ons and the node group

`cli/bin/40-nodegroup.sh` resolves versions, creates three add-ons, then the node group, and returns without waiting.

```bash
aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.36
aws eks create-addon --cluster-name awseks-cli-lab \
  --addon-name eks-pod-identity-agent \
  --addon-version <default from the API> \
  --resolve-conflicts OVERWRITE
aws eks create-addon --cluster-name awseks-cli-lab \
  --addon-name vpc-cni \
  --addon-version v1.23.2-eksbuild.8 \
  --configuration-values '{"enableNetworkPolicy":"true"}' \
  --resolve-conflicts OVERWRITE
aws eks create-addon --cluster-name awseks-cli-lab \
  --addon-name kube-proxy \
  --addon-version v1.36.0-eksbuild.58 \
  --resolve-conflicts OVERWRITE
```

The vpc-cni and kube-proxy versions are pins. The script lists compatible versions first and exits if the pin is absent.

Launch template data has IMDSv2, hop limit 1, encrypted gp3 `/dev/xvda`, and tags. It has no `KeyName` and no user data. EKS selects the AL2023 AMI because the node group sets `amiType` and the template does not set an image id.

```bash
aws ec2 create-launch-template --launch-template-name awseks-cli-lab-nodes \
  --launch-template-data file://cli/state/launch-template.json
aws eks create-nodegroup --cli-input-json file://cli/state/create-nodegroup.json
```

Node group JSON uses `amiType: AL2023_x86_64_STANDARD`, `capacityType: ON_DEMAND`, private subnet ids, `launchTemplate.version: "$Latest"`, and no `remoteAccess`.

## 5. Wait, then CoreDNS and EBS

`cli/bin/50-addons.sh`:

```bash
aws eks wait addon-active --cluster-name awseks-cli-lab --addon-name eks-pod-identity-agent
aws eks wait addon-active --cluster-name awseks-cli-lab --addon-name vpc-cni
aws eks wait addon-active --cluster-name awseks-cli-lab --addon-name kube-proxy
aws eks wait nodegroup-active --cluster-name awseks-cli-lab --nodegroup-name awseks-cli-lab-managed
aws eks create-addon --cluster-name awseks-cli-lab --addon-name coredns \
  --addon-version v1.14.7-eksbuild.22 --resolve-conflicts OVERWRITE
# v1.14.7-eksbuild.22 is the 1.36 CoreDNS row. kube-proxy above is the 1.36 row.
aws eks wait addon-active --cluster-name awseks-cli-lab --addon-name coredns
aws eks create-addon --cluster-name awseks-cli-lab --addon-name aws-ebs-csi-driver \
  --addon-version <default from the API> \
  --resolve-conflicts OVERWRITE \
  --pod-identity-associations serviceAccount=ebs-csi-controller-sa,roleArn=<EBS role ARN>
aws eks wait addon-active --cluster-name awseks-cli-lab --addon-name aws-ebs-csi-driver
```

Waiting for the node group before the first three add-ons exist is the deadlock described in [architecture.md](architecture.md). CoreDNS is a Deployment and waits until a node is Ready.

## 6. Access entries

`cli/bin/60-access.sh`:

```bash
aws eks list-access-entries --cluster-name awseks-cli-lab
```

EXAMPLE entries:

```json
{"accessEntries": [
  "arn:aws:iam::111122223333:role/Admin",
  "arn:aws:iam::111122223333:role/awseks-cli-lab-node"
]}
```

If the node role is missing, the script creates `--type EC2_LINUX` and does not associate `AmazonEKSClusterAdminPolicy`. A healthy managed node group already has that entry when authentication mode is `API`.

## 7. Kubeconfig and verify

```bash
aws eks update-kubeconfig \
  --region us-west-2 \
  --name awseks-cli-lab \
  --kubeconfig cli/state/kubeconfig \
  --alias awseks-cli-lab
export KUBECONFIG=cli/state/kubeconfig
kubectl config current-context
kubectl get --raw='/readyz'
kubectl get nodes -o wide
```

The script compares the kubeconfig server to `cluster.endpoint` and refuses to continue on a mismatch. It does not write `~/.kube/config`.

EXAMPLE `kubectl get nodes`:

```text
NAME                                          STATUS   ROLES    AGE   VERSION
ip-10-0-10-12.us-west-2.compute.internal      Ready    <none>   4m    v1.35.x-eks-...
ip-10-0-11-48.us-west-2.compute.internal      Ready    <none>   4m    v1.35.x-eks-...
```

`80-verify.sh` also rolls out `coredns`, `aws-node`, `kube-proxy`, `eks-pod-identity-agent`, and `ebs-csi-node`, and prints the cluster security group plus the private routes. A `0.0.0.0/0` route whose target is a NAT is VPC egress. It is not the ClusterIP implementation.

## 8. Not part of this bootstrap

Helm for the load balancer controller: [../stages/aws-load-balancer-controller/install.sh](../stages/aws-load-balancer-controller/install.sh) with argument `awscli`. That script uses Helm and kubectl. Metrics Server is optional and is a community add-on: [../stages/metrics-server/install.sh](../stages/metrics-server/install.sh).

## 9. One command

`cli/bin/provision.sh` prints the cost warning and requires the phrase `provision awseks-cli-lab`, then runs steps 0 through 7. It does not run Helm and it does not run cleanup.
