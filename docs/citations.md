# Sources

Read on 2026-11-07 unless a page says otherwise. Quotes in the docs are paraphrases except for CLI flags and version strings copied from those pages.

## EKS versions and add-ons

- Kubernetes version lifecycle: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
- Platform versions: https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html
- VPC CNI versions: https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
- kube-proxy versions: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
- CoreDNS versions: https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
- Add-on compatibility API: https://docs.aws.amazon.com/eks/latest/userguide/addon-compat.html
- EBS CSI and `AmazonEBSCSIDriverPolicyV2`: https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
- Pod Identity agent: https://docs.aws.amazon.com/eks/latest/userguide/pod-id-agent-setup.html
- Pod Identity trust: https://docs.aws.amazon.com/eks/latest/userguide/pod-id-role.html
- Add-on IAM and Pod Identity support table: https://docs.aws.amazon.com/eks/latest/userguide/retreive-iam-info.html
- Metrics Server community add-on: https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
- Amazon Linux 2023: https://docs.aws.amazon.com/eks/latest/userguide/al2023.html

## API and CLI

- CreateCluster: https://docs.aws.amazon.com/eks/latest/APIReference/API_CreateCluster.html
- `aws eks create-cluster`: https://docs.aws.amazon.com/cli/latest/reference/eks/create-cluster.html
- `aws eks create-nodegroup`: https://docs.aws.amazon.com/cli/latest/reference/eks/create-nodegroup.html
- `aws eks create-addon`: https://docs.aws.amazon.com/cli/latest/reference/eks/create-addon.html
- `aws eks wait`: https://docs.aws.amazon.com/cli/latest/reference/eks/wait/index.html
- Deletion protection: https://docs.aws.amazon.com/eks/latest/userguide/deletion-protection.html
- `update-cluster-config`: https://docs.aws.amazon.com/cli/latest/reference/eks/update-cluster-config.html
- Cluster security group: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
- Cluster IAM role: https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html
- Node IAM role: https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
- Access entries: https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html
- Access policy contents: https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html

## Controller, Terraform, image, Karpenter

- Load balancer controller install in the EKS user guide (still chart 1.14.0 and controller v2.14.1 on 2026-11-07): https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
- Upstream controller release v3.6.2: https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/tag/v3.6.2
- Controller Gateway API guide (`/latest/`, states Gateway API v1.6.0): https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/gateway/
- EKS control-plane rollback: https://docs.aws.amazon.com/eks/latest/userguide/rollback-cluster.html
- Auto Mode Gateway API: https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-gateway-api.html
- Security groups for pods, including the Auto Mode API-group warning: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
- Upstream install notes, including Pod Identity: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
- IAM policy file, v3.6.2 URL (same SHA256 as the v2.14.1 URL on 2026-11-07): https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.6.2/docs/install/iam_policy.json
- Terraform AWS provider 6.72.0: https://registry.terraform.io/providers/hashicorp/aws/6.72.0/docs
- `aws_eks_addon_version`: https://registry.terraform.io/providers/hashicorp/aws/6.72.0/docs/data-sources/eks_addon_version
- Terraform 1.17.1: https://github.com/hashicorp/terraform/releases/tag/v1.17.1
- Karpenter compatibility: https://karpenter.sh/docs/upgrading/compatibility/
- Demo image tag `1.30.6`: Docker Hub repository `nginx/nginx-unprivileged`, digest recorded in [versions.md](versions.md)
