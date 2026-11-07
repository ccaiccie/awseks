locals {
  tags = {
    Project    = "awseks-practice"
    ManagedBy  = "terraform"
    Stack      = "03-platform"
    NamePrefix = var.cluster_name
    CostCenter = "eks-networking-masterclass"
  }

  efs_on      = var.enable_efs && var.efs_confirmation == "enable-efs"
  oidc_issuer = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_host   = replace(local.oidc_issuer, "https://", "")
}

module "guardrails" {
  source = "../../modules/guardrails"

  name = var.cluster_name

  check_confirmation    = true
  confirmation_enabled  = var.enable_efs
  confirmation_value    = var.efs_confirmation
  confirmation_expected = "enable-efs"
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = local.oidc_issuer
}

resource "terraform_data" "cluster_ready" {
  lifecycle {
    precondition {
      condition     = contains(["1.34", "1.35", "1.36", "1.37"], data.aws_eks_cluster.this.version)
      error_message = "Stack 03 was reviewed for EKS 1.34-1.37 only."
    }
  }
}

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_chart_version

  # Lab shortcut: EKS kubelet certificates are not in metrics-server's default
  # trust set, so kubectl top fails closed without this flag. It skips kubelet
  # TLS verification. Do not treat that as a production setting.
  values = [
    yamlencode({
      args = ["--kubelet-insecure-tls"]
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    })
  ]

  depends_on = [terraform_data.cluster_ready]
}

module "aws_lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.10.0"

  create = var.enable_aws_load_balancer_controller

  name            = "${var.cluster_name}-aws-lbc"
  use_name_prefix = false
  path            = "/awseks-practice/"

  attach_aws_lb_controller_policy = true
  associations                    = {}

  tags = local.tags
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = data.aws_eks_cluster.this.vpc_config[0].vpc_id
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }
    })
  ]

  depends_on = [module.aws_lb_controller_pod_identity]
}

resource "aws_eks_pod_identity_association" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = module.aws_lb_controller_pod_identity.iam_role_arn

  depends_on = [helm_release.aws_load_balancer_controller]
}

resource "aws_s3_bucket" "identity_demo" {
  count = var.enable_identity_demo ? 1 : 0

  bucket        = "${var.cluster_name}-pod-id-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-pod-id"
  })
}

resource "aws_s3_bucket_public_access_block" "identity_demo" {
  count = var.enable_identity_demo ? 1 : 0

  bucket                  = aws_s3_bucket.identity_demo[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "identity_demo" {
  count = var.enable_identity_demo ? 1 : 0

  bucket = aws_s3_bucket.identity_demo[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "identity_demo" {
  count = var.enable_identity_demo ? 1 : 0

  bucket       = aws_s3_bucket.identity_demo[0].id
  key          = "lab08/hello.txt"
  content      = "practice object for the Pod Identity lab\n"
  content_type = "text/plain"

  depends_on = [aws_s3_bucket_public_access_block.identity_demo]
}

data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "lab_workload" {
  count = var.enable_identity_demo ? 1 : 0

  name               = "${var.cluster_name}-lab-workload"
  path               = "/awseks-practice/"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = local.tags
}

data "aws_iam_policy_document" "lab_workload" {
  count = var.enable_identity_demo ? 1 : 0

  statement {
    sid       = "ListDemoBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.identity_demo[0].arn]
  }

  statement {
    sid       = "ReadDemoObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.identity_demo[0].arn}/lab08/*"]
  }
}

resource "aws_iam_role_policy" "lab_workload" {
  count = var.enable_identity_demo ? 1 : 0

  name   = "lab-workload-read"
  role   = aws_iam_role.lab_workload[0].id
  policy = data.aws_iam_policy_document.lab_workload[0].json
}

resource "kubernetes_namespace_v1" "lab_identity" {
  count = var.enable_identity_demo ? 1 : 0

  metadata {
    name = "lab-identity"
    labels = {
      "app.kubernetes.io/part-of" = "awseks-practice"
      "awseks.practice/owner"     = "terraform"
    }
  }
}

resource "kubernetes_service_account_v1" "lab_pod_identity" {
  count = var.enable_identity_demo ? 1 : 0

  metadata {
    name      = "lab-pod-identity"
    namespace = kubernetes_namespace_v1.lab_identity[0].metadata[0].name
  }
}

resource "kubernetes_service_account_v1" "lab_irsa" {
  count = var.enable_identity_demo ? 1 : 0

  metadata {
    name      = "lab-irsa"
    namespace = kubernetes_namespace_v1.lab_identity[0].metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lab_irsa[0].arn
    }
  }
}

resource "aws_eks_pod_identity_association" "lab_workload" {
  count = var.enable_identity_demo ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace_v1.lab_identity[0].metadata[0].name
  service_account = kubernetes_service_account_v1.lab_pod_identity[0].metadata[0].name
  role_arn        = aws_iam_role.lab_workload[0].arn
}

data "aws_iam_policy_document" "irsa_trust" {
  count = var.enable_identity_demo ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:lab-identity:lab-irsa"]
    }
  }
}

resource "aws_iam_role" "lab_irsa" {
  count = var.enable_identity_demo ? 1 : 0

  name               = "${var.cluster_name}-lab-irsa"
  path               = "/awseks-practice/"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust[0].json

  tags = local.tags
}

resource "aws_iam_role_policy" "lab_irsa" {
  count = var.enable_identity_demo ? 1 : 0

  name = "lab-irsa-list-only"
  role = aws_iam_role.lab_irsa[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListDemoBucketOnly"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.identity_demo[0].arn
      }
    ]
  })
}

resource "aws_security_group" "efs" {
  count = local.efs_on ? 1 : 0

  name        = "${var.cluster_name}-efs"
  description = "NFS from the practice VPC to the optional lab EFS"
  vpc_id      = data.aws_eks_cluster.this.vpc_config[0].vpc_id

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-efs"
  })
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  count = local.efs_on ? 1 : 0

  security_group_id = aws_security_group.efs[0].id
  description       = "NFS from the VPC CIDR"
  ip_protocol       = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_ipv4         = data.aws_vpc.this.cidr_block
}

resource "aws_vpc_security_group_egress_rule" "efs" {
  count = local.efs_on ? 1 : 0

  security_group_id = aws_security_group.efs[0].id
  description       = "Return traffic into the VPC"
  ip_protocol       = "-1"
  cidr_ipv4         = data.aws_vpc.this.cidr_block
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.this.vpc_config[0].vpc_id]
  }

  filter {
    name   = "tag:awseks.practice/subnet-role"
    values = ["private-worker"]
  }
}

resource "aws_efs_file_system" "lab" {
  count = local.efs_on ? 1 : 0

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(local.tags, {
    Name = "${var.cluster_name}-lab"
  })
}

resource "aws_efs_mount_target" "lab" {
  for_each = local.efs_on ? toset(data.aws_subnets.private.ids) : toset([])

  file_system_id  = aws_efs_file_system.lab[0].id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs[0].id]
}

module "efs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.10.0"

  create = local.efs_on

  name            = "${var.cluster_name}-efs-csi"
  use_name_prefix = false
  path            = "/awseks-practice/"

  attach_aws_efs_csi_policy = true
  associations              = {}

  tags = local.tags
}

resource "aws_eks_addon" "efs_csi" {
  count = local.efs_on ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = var.efs_csi_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.tags

  depends_on = [module.efs_csi_pod_identity]
}

resource "aws_eks_pod_identity_association" "efs_csi" {
  count = local.efs_on ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
  role_arn        = module.efs_csi_pod_identity.iam_role_arn

  depends_on = [aws_eks_addon.efs_csi]
}
