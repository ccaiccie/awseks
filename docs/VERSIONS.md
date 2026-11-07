# Versions reviewed on 2026-11-07

These pins are what the Terraform in this repository asks for. Confirm addon builds in your Region on the day you teach. `scripts/check-addon-versions.sh` is a read-only check and needs credentials. CI does not run it.

| Component | Pin | Source |
| --- | --- | --- |
| Terraform CLI | 1.17.1 in CI; `required_version` is `>= 1.10.0` | [HashiCorp releases](https://releases.hashicorp.com/terraform/) |
| AWS provider | 6.72.0 | [hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest) published 2026-11-04 |
| EKS module | 21.29.0, requires AWS provider `>= 6.59` | [terraform-aws-modules/eks v21.29.0](https://github.com/terraform-aws-modules/terraform-aws-eks/releases/tag/v21.29.0) |
| VPC module | 6.7.3, requires AWS provider `>= 6.28` | [terraform-aws-modules/vpc/aws 6.7.3](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) |
| Pod Identity module | 2.10.0 | [terraform-aws-modules/eks-pod-identity/aws 2.10.0](https://registry.terraform.io/modules/terraform-aws-modules/eks-pod-identity/aws/latest) |
| Helm provider | 3.3.0 | [hashicorp/helm](https://registry.terraform.io/providers/hashicorp/helm/latest) |
| Kubernetes provider | 3.5.0 | [hashicorp/kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) published 2026-11-05 |
| Kubernetes on EKS | default 1.35; allowed 1.34, 1.35, 1.36, 1.37 | [EKS version lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) |
| VPC CNI addon | v1.23.2-eksbuild.8 for 1.34-1.37 | [Managing the VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html) |
| CoreDNS addon | 1.34: v1.13.2-eksbuild.62; 1.35-1.37: v1.14.7-eksbuild.22 | [Managing CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) |
| kube-proxy addon | 1.34 v1.34.6-eksbuild.62; 1.35 v1.35.3-eksbuild.62; 1.36 v1.36.0-eksbuild.58; 1.37 v1.37.0-eksbuild.32 | [Managing kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) |
| EBS CSI addon | v1.67.2-eksbuild.1 | Driver v1.67.2 was released 2026-10-26. The EKS addon build `v1.67.2-eksbuild.1` is the build cited by the AWS addon configuration schema snapshot on Chainguard, retrieved 2026-11-07. The AWS user-guide sample still shows an older default. **Re-check with `describe-addon-versions` before apply.** |
| Pod Identity agent | not pinned | AWS does not publish a per-minor table comparable to kube-proxy. Leave the variable null to resolve `most_recent` at apply, then pin the value this script prints. A June 2026 field report used `v1.3.10-eksbuild.2` on 1.34. That is not a November recommendation. |
| AWS Load Balancer Controller chart | 3.6.2 | [Artifact Hub chart 3.6.2](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller/) updated 2026-10-24 |
| Gateway API CRDs | v1.6.0 standard channel, not installed by Terraform | [LBC v3.5.0 release](https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/tag/v3.5.0) requires Gateway API CRDs v1.6.0. Confirm the 3.6 page before class. |
| metrics-server chart | 3.14.0 (image v0.9.0) | [kubernetes-sigs/metrics-server chart](https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/README.md) |
| Karpenter chart | 1.15.1, optional | [Compatibility matrix](https://karpenter.sh/docs/upgrading/compatibility/): 1.35 needs `>= 1.9`, 1.36 needs `>= 1.13`, 1.37 lists `1.15.x`. [Getting started](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/) pins 1.15.1 with Kubernetes 1.36 in its sample. |
| Example app image | `nginxinc/nginx-unprivileged:1.29` index digest `sha256:18d5312e3b7e455cf9e4fb8becfc2dafaf98063dab542759c2a38708956574b7` | Read from `registry-1.docker.io` on 2026-11-07. The index lists linux/amd64 and linux/arm64. The process listens on 8080 and runs as uid 101. |
| Identity probe image | `public.ecr.aws/aws-cli/aws-cli` linux/amd64 digest `sha256:3a51e4b63c34883f1fff4a6f2f6a82b0b4bd16a2ea693e875d06a4f406a5f6c7` | Manifest list for tag `latest` on public ECR, 2026-11-07. The tag moves. The digest does not. The image runs as root and is only the identity probe. |

## Support windows that matter in class

From the EKS lifecycle page retrieved 2026-11-07:

| Version | End of standard support | End of extended support |
| --- | --- | --- |
| 1.34 | 2026-12-02 | 2027-12-02 |
| 1.35 | 2027-03-27 | 2028-03-27 |
| 1.36 | 2027-08-02 | 2028-08-02 |
| 1.37 | 2027-12-01 | 2028-12-01 |

`upgrade_policy.support_type` is `STANDARD`. A cluster left on 1.34 past 2026-12-02 is billed at the extended rate even if this file still lists 1.34 as allowed.

## Lock files

`.terraform.lock.hcl` is committed after `terraform init`. Provider hashes are for the platforms Terraform recorded on the machine that generated the lock. CI uses linux_amd64.
