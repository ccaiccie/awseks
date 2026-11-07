# awseks

Practice repository for a standard Amazon EKS networking class. It builds a dedicated IPv4 VPC, a standard EKS cluster with managed EC2 nodes, and the current managed add-ons. Labs then use kubectl. Terraform does not own those lab objects, and the labs do not create a second cluster.

Nothing in this repository has been applied to AWS. `terraform validate` and the unit tests check configuration only.

## What you get

| Path | Owns |
| --- | --- |
| `terraform/stacks/01-network` | VPC, subnets, NAT, S3 gateway endpoint, optional interface endpoints and flow logs |
| `terraform/stacks/02-cluster` | Standard EKS, managed node group, access entries, VPC CNI, kube-proxy, CoreDNS, Pod Identity agent, EBS CSI |
| `terraform/stacks/03-platform` | metrics-server, AWS Load Balancer Controller, identity-demo bucket and roles, optional EFS |
| `terraform/stacks/04-karpenter` | Optional Karpenter IAM, interruption queue, and Helm release. Off unless you opt in |
| `manifests/` | Student workloads. kubectl apply. Not in Terraform state |
| `labs/` | Progressive labs |

Auto Mode, Fargate, and self-managed nodes are explained in [docs/COMPUTE-MODES.md](docs/COMPUTE-MODES.md). They are not what the stacks create.

## Cost before you apply

A default apply is a real bill, not a free tier exercise. Published rates retrieved 2026-11-07:

- EKS standard support is **$0.10 per cluster-hour**. Extended support is **$0.60**. Kubernetes 1.34 leaves standard support on 2026-12-02. The default version is 1.35. Source: [Amazon EKS pricing](https://aws.amazon.com/eks/pricing/).
- The VPC pricing example rate for a NAT gateway is **$0.045 per hour plus $0.045 per GB**, and the example says regional rates differ. One NAT is the default. One per AZ is an opt-in. Source: [Amazon VPC pricing](https://aws.amazon.com/vpc/pricing/).
- Two `t3.medium` nodes, a public IPv4 on the NAT gateway, and any load balancer you create in the labs are extra. gp3 volumes are small. Interface VPC endpoints and EFS stay off until you type the confirmation string.

Read [docs/COST.md](docs/COST.md) before the first apply. Destroy with [docs/CLEANUP.md](docs/CLEANUP.md). Workflows never run apply or destroy.

## Versions

Pins, sources, and the retrieval date are in [docs/VERSIONS.md](docs/VERSIONS.md). Re-run `scripts/check-addon-versions.sh` on the day of class. That script is read-only.

## Apply, by hand

You need Terraform 1.17.x (1.10 or newer is accepted), AWS CLI v2, kubectl, and Helm 3. The IAM caller needs [terraform/iam/lab-operator-policy.json](terraform/iam/lab-operator-policy.json) plus [terraform/iam/permissions-boundary.json](terraform/iam/permissions-boundary.json). `iam:PassRole` is limited to `role/awseks-practice/*` and to `eks.amazonaws.com`, `ec2.amazonaws.com`, and `pods.eks.amazonaws.com`. The policy is not `AdministratorAccess`.

```bash
aws sts get-caller-identity
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export AWS_REGION=us-west-2
export CLUSTER_NAME=eks-lab
./scripts/render-operator-policy.sh > /tmp/lab-operator.json
# Review /tmp/lab-operator.json. Create the policy and boundary in IAM yourself.
```

```bash
cd terraform/stacks/01-network
cp terraform.tfvars.example terraform.tfvars
# edit region and name
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
# Read the plan. Then, only if it matches the VPC you expect:
terraform apply tfplan
```

Repeat plan and a reviewed apply for `02-cluster`. Set `admin_principal_arns` to the ARN from `aws sts get-caller-identity`. Leave the public API off, or set `endpoint_public_access = true` and `endpoint_public_access_cidrs` to your `/32`. `0.0.0.0/0` does not plan.

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
kubectl get nodes
kubectl get pods -n kube-system
```

Apply `03-platform` only after those commands succeed. Apply `04-karpenter` only for lab 15, with `karpenter_confirmation = "enable-karpenter"`.

There is no `local-exec` provisioner. Terraform does not update kubeconfig for you.

## Labs

Start at [labs/README.md](labs/README.md). Early labs assume stacks 01 and 02. Load balancer labs need stack 03. Each lab tells you which track owns the objects so you do not create them twice.

## Static checks

```bash
./scripts/static-validate.sh
```

That command formats, tests the pure modules, runs `terraform init -backend=false` and `terraform validate`, shellchecks the scripts, parses the manifests, and runs kubeconform. It does not prove the cluster boots.

## State

State is local and gitignored. An S3 backend example sits next to each stack. Do not commit `terraform.tfvars`, `*.tfstate`, keys, or kubeconfig.
