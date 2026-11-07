# Amazon EKS practice lab and masterclass

This repository holds two things that stay separate.

**Practice.** A standard Amazon EKS lab on managed EC2, Amazon Linux 2023, IPv4. It is not an Auto Mode lab. You can build the same shape of cluster two ways. Those ways do not share a name, a state file, or a resource.

**Class.** A 26-chapter novice-to-expert masterclass: **335 scenes**, measured at **2:09:55** (7795.372 seconds). The editable lecture diagram is [class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio](class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio), SHA256 `6e73873cc031bf0d84202a45798a1aea6bf966fdc7ffe28f3e20624c46135b23`. The chapter timing is [class/build/SCENE-CHAPTER-MAP.md](class/build/SCENE-CHAPTER-MAP.md). Transcripts are [class/docs/TRANSCRIPT.md](class/docs/TRANSCRIPT.md) and [class/docs/SPOKEN-TRANSCRIPT.txt](class/docs/SPOKEN-TRANSCRIPT.txt).

The HTML master is not in git. The pinned file `AWS-EKS-Masterclass-Novice-to-Expert-v5.1-YouTube-Edition.html` is 66,655,838 bytes, SHA256 `a23d6854e93cd4fbb22acded84766b9ae67c6ec159417791f21901ec5d3b7058`. It was delivered privately as four volumes plus a reassembly helper. This README does not offer a download URL.

No cluster was created from this repository. `terraform validate` and the shell checks do not call AWS. Snapshot version pins in [docs/versions.md](docs/versions.md) are what the public docs said on 2026-11-07. They are not proof that an API deploy succeeded.

## Which diagram to open

| You want | Open |
| --- | --- |
| The lecture and flow diagram with native AWS and Kubernetes art | [class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio](class/diagrams/EKS-Masterclass-v5.1-Lecture-and-Flow.drawio) |
| Where each of the 335 scenes sits in the 26 chapters | [class/build/SCENE-CHAPTER-MAP.md](class/build/SCENE-CHAPTER-MAP.md) |
| The earlier static reference geometry (conceptual boxes, F01–F29, PNG previews) | [class/diagrams/README.md](class/diagrams/README.md) and `class/diagrams/eks-scenarios.drawio` |
| The practice-lab route and identity sketches | [docs/diagrams/README.md](docs/diagrams/README.md) |
| Which practice lab matches which chapter | [docs/chapter-map.md](docs/chapter-map.md) |

v2 through v5 lecture draw.io files are kept and superseded. v5 uses base64 image URIs. v5.1 uses percent-encoded SVG data URIs. Use v5.1.

Builder checks on the pinned HTML reported 17,630 control states, 276 audio decodes, syntax checks, and a successful four-volume reassembly. Those checks are not a full listen of the 2:09:55 timeline, not an AWS apply, and not a diagrams.net GUI import. A follow-up review of the percent-encoded image URIs is still in flight, so this README does not call the companion an independent final pass. The builder's own native style parser reported 258/258 image payloads intact. See [class/VALIDATION.md](class/VALIDATION.md) and [class/BUILD-STATUS.json](class/BUILD-STATUS.json).

## Who it is for

You can start from "what is a Pod" and finish at identity, ingress, storage, disruption, and cost. You need:

- An AWS account you are allowed to spend money in, and an IAM principal that can create the resources in [policies/operator-baseline.json](policies/operator-baseline.json). That file is a review aid. Nothing here attaches it for you.
- AWS CLI v2, kubectl, Helm 3, jq, and Python 3. Terraform 1.17.1 is required only for the Terraform path.
- A region where `aws eks describe-cluster-versions --version-status STANDARD_SUPPORT` still lists the minor you select. On 2026-11-07 that command's documented set was 1.34, 1.35, 1.36, and 1.37. The preflight uses the live response.

You do not need SSH keys. Nodes are not given one.

## What you get

A VPC in at least two Availability Zones, private worker subnets, public subnets for NAT and load balancers, a standard EKS control plane with the private API enabled, a managed node group on Amazon Linux 2023, and managed add-ons for the VPC CNI, kube-proxy, CoreDNS, the Pod Identity agent, and the EBS CSI driver. The AWS Load Balancer Controller is a later Helm stage so Terraform does not talk to the Kubernetes API in the same plan that creates the cluster.

## Architecture

```text
Internet gateway
  -> public subnets (NAT, optional load balancers)
  -> private subnets (control plane ENIs, AL2023 nodes, pod IPs)
EKS API: private always, public only from CIDRs you name
```

The picture is [docs/diagrams/01-architecture.svg](docs/diagrams/01-architecture.svg). Read [docs/architecture.md](docs/architecture.md) and [docs/network-model.md](docs/network-model.md) before you change a route table. A VPC route, a Kubernetes Service, and an IAM decision are three different checks.

## Two paths

| Path | Cluster name | Who creates the VPC and cluster | State |
| --- | --- | --- | --- |
| [Terraform](terraform/README.md) | `awseks-tf-lab` | Terraform resources only | local `terraform/terraform.tfstate`, gitignored |
| [AWS CLI](docs/cli-walkthrough.md) | `awseks-cli-lab` | `cli/bin/*.sh` only | `cli/state/cluster.env`, gitignored |

AWS CLI on the Terraform path is for identity, `describe-addon-versions`, and `aws eks update-kubeconfig`. Terraform is not used on the CLI path. Do not point either path at the other cluster name. The prefixes are checked in variables and in the shell.

Quick start:

1. Read [docs/cost.md](docs/cost.md). Stop if you cannot leave the resources running and still delete them.
2. Pick one path and follow it to a Ready node.
3. Run labs in [labs/README.md](labs/README.md). Manifests live in [manifests/](manifests/).
4. Delete Ingress objects, load balancers, and PVCs before the cluster. Then follow [docs/cleanup.md](docs/cleanup.md).

## Folder map

| Path | Purpose |
| --- | --- |
| `terraform/` | VPC, IAM, standard EKS cluster, managed node group, managed add-ons |
| `cli/bin/` | The same shape, as AWS CLI commands with waits and a state file |
| `stages/` | Helm and optional add-ons that are not part of cluster bootstrap |
| `manifests/` | Kubernetes YAML. Applying it needs a kubeconfig |
| `labs/` | Objectives, commands, expected observations, and failure tests |
| `class/` | Curriculum, `eksclass-cli-` labs, static reference diagrams, and the v5.1 lecture diagram |
| `class/build/SCENE-CHAPTER-MAP.md` | Measured 26-chapter, 335-scene timing |
| `docs/diagrams/` | Smaller sketches for the practice write-up. Not the lecture diagram |
| `docs/chapter-map.md` | Practice labs lined up with chapters. Not the 335-scene timing map |
| `policies/` | Vendored controller IAM policy and an operator baseline |
| `.github/workflows/static.yml` | Static checks only. No AWS credentials and no deploy |

## End-to-end setup

Install the tools and confirm the CLI is v2:

```bash
aws --version
kubectl version --client
helm version --short
jq --version
terraform version
```

Configure a profile or IAM Identity Center yourself. Do not put access keys in the shell history of this lab, and do not commit them. `aws sts get-caller-identity` prints the account and the caller ARN. That is the check the scripts use.

Terraform, after [terraform/README.md](terraform/README.md):

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
```

Read `tfplan`. Apply only when the plan matches the cluster you meant:

```bash
terraform apply tfplan
aws eks update-kubeconfig --region "$(terraform output -raw region)" \
  --name "$(terraform output -raw cluster_name)" \
  --kubeconfig "./kubeconfig-$(terraform output -raw cluster_name)" \
  --alias "$(terraform output -raw cluster_name)"
```

AWS CLI:

```bash
cp cli/config.env.example cli/config.env
# edit region, and a real /32 if you enable the public API
cli/bin/provision.sh
```

`provision.sh` asks you to type `provision awseks-cli-lab` after the cost warning. It runs preflight, network, IAM, cluster, node group, add-ons, access check, kubeconfig, and verify. It does not install Helm.

Expected verify checkpoint, once a real cluster exists: at least two nodes `Ready`, and `coredns`, `aws-node`, `kube-proxy`, `eks-pod-identity-agent`, and `ebs-csi-node` rolled out in `kube-system`. Example ids in the walkthrough are fake.

## Cost warning, before you provision

The control plane, NAT gateway, and two `t3.medium` nodes are billed until you delete them. `nat_strategy = per_az` multiplies NAT gateways. `nat_strategy = none` forces interface VPC endpoints, which are also billed. Control plane logs, flow logs, and extra load balancers add ingestion and hourly charges. Prices change. Read [docs/cost.md](docs/cost.md) and the AWS pricing pages before `terraform apply` or `cli/bin/provision.sh`. This repository does not embed a price quote.

New clusters would enter extended support unless the support type is set. Both paths set `STANDARD`.

## Versions, support, and limits

Pins, the date they were read, and how to re-check them are in [docs/versions.md](docs/versions.md).

- Terraform 1.17.1 and AWS provider 6.72.0.
- Default Kubernetes minor 1.36, the class teaching baseline. Whether it is still in standard support is a live `describe-cluster-versions` result.
- Default AMI `AL2023_x86_64_STANDARD`. No SSH key. IMDSv2 required, hop limit 1.
- Dated user-guide pins for VPC CNI, kube-proxy, and CoreDNS are in [docs/versions.md](docs/versions.md). Apply-time selection still checks `describe-addon-versions`. Pod Identity Agent, EBS CSI, and Metrics Server use that API's default compatible build.
- AWS Load Balancer Controller upstream release `v3.6.2` with Helm chart `3.6.2`. Gateway API `v1.6.0` is the mapping on the v3.6 controller guide. The EKS user-guide install page fetched the same day still shows chart `1.14.0`; this repo does not follow that older example. See [docs/versions.md](docs/versions.md).
- Demo image `nginx/nginx-unprivileged@sha256:847080049e23239e86144f01a4b79252db60494cebea58e827ae4e7d66c96c58`, tag `1.30.6` on Docker Hub on 2026-11-07. It listens on 8080 as a non-root user.

Limits that are easy to miss:

- IPv6, Auto Mode, and Fargate are comparison reading in [labs/14-comparisons.md](labs/14-comparisons.md). They are not provisioned and their features are not claimed for this cluster.
- Karpenter is not installed. The compatibility matrix fetched on 2026-11-07 lists Kubernetes 1.36 as Karpenter `>= 1.13`. Do not run it beside Cluster Autoscaler on the same capacity.
- The public API rejects `0.0.0.0/0` and documentation ranges such as `203.0.113.10/32`.
- `vpc_cni_use_pod_identity` stays false on the first apply. See [docs/iam.md](docs/iam.md).
- Static CI does not prove a cluster will become ACTIVE.

## Lab map

| Stage | Lab |
| --- | --- |
| Tools, cost, identity | [labs/01-orientation.md](labs/01-orientation.md) |
| Pods, probes, config, limits | [labs/02-workloads.md](labs/02-workloads.md) |
| Terraform path | [labs/03-terraform-path.md](labs/03-terraform-path.md) |
| AWS CLI path | [labs/04-aws-cli-path.md](labs/04-aws-cli-path.md) |
| API access and kubeconfig | [labs/05-api-access.md](labs/05-api-access.md) |
| IAM, access entries, RBAC, PassRole | [labs/06-iam.md](labs/06-iam.md) |
| CNI, DNS, ClusterIP, NAT, endpoints | [labs/07-networking.md](labs/07-networking.md) |
| NetworkPolicy, security groups, NACLs | [labs/08-policy-and-load-balancers.md](labs/08-policy-and-load-balancers.md) |
| Storage, scale, upgrades, cleanup | [labs/09-operate.md](labs/09-operate.md) |
| IPv6, Auto Mode, Fargate | [labs/14-comparisons.md](labs/14-comparisons.md) |
| Full 26-chapter class | [docs/chapter-map.md](docs/chapter-map.md) |

The chapter map that the finished class should follow is [docs/chapter-map.md](docs/chapter-map.md).

## Diagrams

The lecture diagram and the measured chapter map are linked above. Static F01–F29 SVG and PNG files stay in [class/diagrams/](class/diagrams/README.md) as the reference geometry. Practice sketches stay in [docs/diagrams/](docs/diagrams/README.md). The practice chapter table is [docs/chapter-map.md](docs/chapter-map.md). The index of what each class file is for is [docs/class-index.md](docs/class-index.md).

## Troubleshooting and cleanup

[docs/troubleshooting.md](docs/troubleshooting.md) lists checkpoints and what to do when a wait times out. [docs/cleanup.md](docs/cleanup.md) deletes Ingress and PVCs first, then the controller, node group, cluster, and only the VPC ids this lab recorded. Cleanup asks you to type the cluster name. It will not delete every VPC in the account.

## Citations

Sources for versions and CLI flags are in [docs/citations.md](docs/citations.md).

## Static checks versus a real cloud run

[docs/validation.md](docs/validation.md) says which commands were run here. `terraform init -backend=false`, `terraform validate`, `bash -n`, and ShellCheck do not create a cluster. A green static check is not an apply.
