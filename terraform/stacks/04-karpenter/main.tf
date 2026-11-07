locals {
  tags = {
    Project    = "awseks-practice"
    ManagedBy  = "terraform"
    Stack      = "04-karpenter"
    NamePrefix = var.cluster_name
    CostCenter = "eks-networking-masterclass"
  }

  karpenter_on = var.enable_karpenter && var.karpenter_confirmation == "enable-karpenter"
}

module "guardrails" {
  source = "../../modules/guardrails"

  name = var.cluster_name

  check_confirmation    = true
  confirmation_enabled  = var.enable_karpenter
  confirmation_value    = var.karpenter_confirmation
  confirmation_expected = "enable-karpenter"
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "terraform_data" "karpenter_compat" {
  lifecycle {
    precondition {
      condition     = contains(["1.34", "1.35", "1.36", "1.37"], data.aws_eks_cluster.this.version)
      error_message = "This Karpenter pin was checked for EKS 1.34 through 1.37 only."
    }
    precondition {
      condition     = var.allow_untested_karpenter_version || var.karpenter_chart_version == "1.15.1"
      error_message = "karpenter_chart_version is pinned to 1.15.1. Set allow_untested_karpenter_version only after you read https://karpenter.sh/docs/upgrading/compatibility/."
    }
  }
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.29.0"

  create = local.karpenter_on

  cluster_name = var.cluster_name

  iam_role_name            = "${var.cluster_name}-karpenter"
  iam_role_use_name_prefix = false
  iam_role_path            = "/awseks-practice/"

  node_iam_role_name            = "${var.cluster_name}-karpenter-node"
  node_iam_role_use_name_prefix = false
  node_iam_role_path            = "/awseks-practice/"

  create_pod_identity_association = false
  create_access_entry             = true
  enable_spot_termination         = true

  tags = local.tags
}

resource "helm_release" "karpenter" {
  count = local.karpenter_on ? 1 : 0

  name       = "karpenter"
  namespace  = "kube-system"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_chart_version

  # Upstream's getting-started sample requests 1 CPU and 1Gi. A two-node
  # t3.medium lab cannot spare that and still schedule the system pods, so
  # this stack requests less. Raise it if the controller is CPU throttled.
  values = [
    yamlencode({
      settings = {
        clusterName       = var.cluster_name
        interruptionQueue = module.karpenter.queue_name
      }
      serviceAccount = {
        create = true
        name   = "karpenter"
      }
      replicas = 1
      controller = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }
    })
  ]

  depends_on = [
    module.karpenter,
    terraform_data.karpenter_compat,
  ]
}

resource "aws_eks_pod_identity_association" "karpenter" {
  count = local.karpenter_on ? 1 : 0

  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = module.karpenter.iam_role_arn

  depends_on = [helm_release.karpenter]
}
