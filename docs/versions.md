# Versions

Fetched and checked on **2026-11-07**. Re-check before you teach from this file again. A pin that `describe-addon-versions` no longer lists must be updated on purpose. The scripts fail closed instead of substituting a different build.

## Platform

| Piece | Pin | Where it was read |
| --- | --- | --- |
| Terraform CLI | 1.17.1 | HashiCorp install page and the 1.17.1 GitHub release, 28 Oct 2026 |
| AWS provider | 6.72.0 | Terraform Registry, published 4 Nov 2026 |
| Kubernetes minors on the 2026-11-07 lifecycle page | 1.34, 1.35, 1.36, 1.37 | Snapshot only. `aws eks describe-cluster-versions --version-status STANDARD_SUPPORT` is the check the CLI preflight runs |
| Default minor | 1.36 | Class teaching baseline. Standard support on the lifecycle page. 1.37 shipped 1 Oct 2026 and is accepted, but it is the newest minor |
| Support type | STANDARD | `create-cluster` documents that new clusters would use extended support unless this is set |
| Node AMI | `AL2023_x86_64_STANDARD` | `create-nodegroup` AMI type list. AL2 EKS-optimized AMIs stopped being published on 26 Nov 2025 |
| AWS CLI | v2, docs site revision observed as 2.39.x | `aws --version` must print `aws-cli/2.` |

Extended-support minors 1.31, 1.32, and 1.33 are rejected so a lab cluster does not pick up the extended-support price by accident.

## Add-ons for the default minor 1.36

| Add-on | Version used | How it was chosen |
| --- | --- | --- |
| vpc-cni | `v1.23.2-eksbuild.8` | EKS user guide VPC CNI table. The same build is listed for 1.34 through 1.37 |
| kube-proxy | `v1.36.0-eksbuild.58` | EKS user guide kube-proxy table for 1.36. The 1.35 row is `v1.35.3-eksbuild.62` |
| coredns | `v1.14.7-eksbuild.22` | EKS user guide CoreDNS table. 1.35 and 1.37 use this build too. 1.34 uses `v1.13.2-eksbuild.62` |
| eks-pod-identity-agent | default from `describe-addon-versions` | The user-guide CLI example still shows `v1.0.0-eksbuild.1`, which is not a current recommendation. Hybrid-node text only gives a minimum (`v1.3.3-eksbuild.1`). This lab does not invent an eksbuild |
| aws-ebs-csi-driver | default from `describe-addon-versions` | Pod Identity is supported since `v1.26.0-eksbuild.1`. A sample on the IAM page is for Kubernetes 1.33 (`v1.66.0-eksbuild.1`) and is not reused as the 1.35 pin |
| metrics-server | default at install time | Community add-on. Minimum called out for hybrid nodes is `v0.7.2-eksbuild.1`. Not installed by the base path |

Other pinned kube-proxy builds, from the same table: 1.34 `v1.34.6-eksbuild.62`, 1.36 `v1.36.0-eksbuild.58`, 1.37 `v1.37.0-eksbuild.32`.

Re-check:

```bash
aws eks describe-addon-versions \
  --addon-name vpc-cni \
  --kubernetes-version 1.36 \
  --query 'addons[0].addonVersions[].{version:addonVersion,default:compatibilities[?clusterVersion==`1.36`].defaultVersion}'
```

The CLI path runs that API and refuses a pin that is not in the list. Terraform stores the three table pins in `terraform/locals.tf` and resolves the other two with `aws_eks_addon_version` (default version, `most_recent` left unset).

## Controller, image, and Karpenter

| Piece | Pin | Note |
| --- | --- | --- |
| AWS Load Balancer Controller IAM | same bytes at v2.14.1 and v3.6.2 | SHA256 `16f232c9d9f79366fe949c4550ad517a202380058a9e48d45a4e215044a20a6a` |
| Helm chart used by this repo and the class scripts | `3.6.2` / appVersion `v3.6.2` | Chart tarball SHA256 `9255bf39873b6cb31106dbe61dc87c3617bff4197783b5b94381811a13f99c3c`, stored under `class/sources/` |
| EKS user-guide install example | chart `1.14.0`, controller text `v2.14.1` | Re-fetched `lbc-helm.html` on 2026-11-07. That page has not caught up with the upstream release. Do not describe 1.14.0 as the current controller |
| Demo image | `nginx/nginx-unprivileged@sha256:847080049e23239e86144f01a4b79252db60494cebea58e827ae4e7d66c96c58` | Docker Hub tag `1.30.6` on 2026-11-07. amd64 image digest on that tag was `sha256:e17bfe33eecc8fd86ca9f12c665f21270b0d88b09a0f13bfdede3fcd795f5fda` |
| Karpenter | not installed | Compatibility matrix: Kubernetes 1.35 needs Karpenter `>= 1.9`. Kubernetes 1.37 is listed as `1.15.x` on the docs home matrix |

The controller policy uses `Resource: "*"` on some describe and listener actions because that is the upstream file. It is not `Action: "*"` and it is not `AdministratorAccess`.

Gateway API v1.6.0 is what the controller `/latest/` guide said on 2026-11-07 (`class/sources/S29.txt`): L7 routes from controller >= 2.14.0, L4 routes from >= 2.13.3, and "built for Gateway API version v1.6.0". The versioned URL `.../v3.6.2/guide/gateway/gateway/` returned 404 on that date, and the v3.6.2 release notes snapshot does not itself name Gateway API 1.6.0. Treat 3.6.2 and Gateway API 1.6.0 as a pair only after you open the guide for the chart you install. Do not copy CRDs from `refs/heads/main`.

## Conditional control-plane rollback

Amazon EKS documents rollback of an in-place upgrade to the previous minor only, and only if you start it within 7 days of that upgrade completing (`class/sources/S50.txt`, and the lifecycle page `S01.txt`). The live page is https://docs.aws.amazon.com/eks/latest/userguide/rollback-cluster.html. It is not a general downgrade. The cluster must already be ACTIVE, must have been upgraded rather than created at the current version, and must not have an enabled EKS feature the previous version rejects. Extended-support targets need the upgrade policy set to `EXTENDED` first.

Before the control-plane call, downgrade EKS add-ons whose builds are incompatible with the target minor, then move Standard managed or self-managed nodes so kubelet is not newer than that API. Auto Mode rolls its own nodes back as part of the control-plane rollback. Fargate is not a managed node group. After the control plane reports the previous minor, verify add-ons and workloads. `--force` is not the default. Preserving etcd data during rollback is not the same as restoring an older application snapshot. The command sequence is in `class/labs/EXPERT-COMMANDS.md`. F28 in `class/diagrams/F28.svg` shows add-on downgrade, then nodes, then the control plane, then verification.

## Auto Mode, only when that mode is on

This repository's Terraform and AWS CLI paths do not enable Auto Mode. The Auto Mode pages, snapshotted the same day, say:

- Gateway API is supported after `elasticLoadBalancing` gateway configuration is enabled. Controller names include `eks.amazonaws.com/gateway-alb`. The documented route types on that page are HTTPRoute, GRPCRoute, TCPRoute, and UDPRoute. TLSRoute is not in that list. LBC's own guide does list TLSRoute for the controller. Do not treat those as the same feature.
- Security groups for Pods on Auto Mode use a `SecurityGroupPolicy` in API group `eks.amazonaws.com/v1` on Kubernetes 1.36 or later. The standard `vpcresources.k8s.aws` manifest is a different spec and is not portable. The standard feature also excludes the `t` instance family for trunking.

## Image digests observed without a deployment

| Image | What was requested | Digest |
| --- | --- | --- |
| `nginx/nginx-unprivileged:1.30.6` | Docker Hub tag API on 2026-11-07 | manifest list `sha256:847080049e23239e86144f01a4b79252db60494cebea58e827ae4e7d66c96c58`; linux/amd64 `sha256:e17bfe33eecc8fd86ca9f12c665f21270b0d88b09a0f13bfdede3fcd795f5fda` |
| `registry.k8s.io/e2e-test-images/agnhost:2.53` | `GET /v2/e2e-test-images/agnhost/manifests/2.53` with an OCI index Accept header | manifest list `sha256:99c6b4bb4a1e1df3f0b3752168c89358794d02258ebebc26bf21c29399011a85`; linux/amd64 `sha256:1c5d47ecd9c4fca235ec0eeb9af0c39d8dd981ae703805a1f23676a9bf47c3bb`; linux/arm64 `sha256:240f70d1e35ea70f9b83666607f08a25f40b15b4f6b28ab61ae6149f56f99250` |

The class CLI scripts still refuse to run until `APP_IMAGE`, `AWSCLI_IMAGE`, and `DEBUG_IMAGE` are set to digests you have reviewed. The agnhost value above is the manifest-list digest returned by the registry. It is not written into `class/labs/config.example.env`. Repo demo manifests keep the nginx digest, which is a different image.

## kubectl

Use a kubectl minor within one of the cluster minor. For the default cluster, that is 1.36.x. The preflight prints `kubectl version --client` and does not download a binary.
