data "aws_iam_policy_document" "cluster_trust" {
  statement {
    sid     = "EksControlPlaneAssumesThisRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_trust" {
  statement {
    sid     = "Ec2NodesAssumeThisRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ebs_pod_identity_trust" {
  statement {
    sid     = "AllowEksAuthToAssumeRoleForPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = ["kube-system"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = ["ebs-csi-controller-sa"]
    }
  }
}

data "aws_iam_policy_document" "lbc_pod_identity_trust" {
  statement {
    sid     = "AllowEksAuthToAssumeRoleForPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = ["kube-system"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = ["aws-load-balancer-controller"]
    }
  }
}

data "aws_iam_policy_document" "vpc_cni_pod_identity_trust" {
  statement {
    sid     = "AllowEksAuthToAssumeRoleForPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = ["kube-system"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = ["aws-node"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster_trust.json
  description        = "Control plane role for ${var.cluster_name}. Not a human admin role."
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource_controller" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node"
  assume_role_policy = data.aws_iam_policy_document.node_trust.json
  description        = "Instance role for managed nodes in ${var.cluster_name}. kubelet and the pod identity agent use it. Workloads should not."
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_pull" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  count = var.vpc_cni_use_pod_identity ? 0 : 1

  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "vpc_cni" {
  count = var.vpc_cni_use_pod_identity ? 1 : 0

  name               = "${var.cluster_name}-vpc-cni"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_pod_identity_trust.json
  description        = "Pod Identity role for the aws-node service account."
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = var.vpc_cni_use_pod_identity ? 1 : 0

  role       = aws_iam_role.vpc_cni[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_pod_identity_trust.json
  description        = "Pod Identity role for ebs-csi-controller-sa. Distinct from the node role."
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"
}

resource "aws_iam_role" "load_balancer_controller" {
  name               = "${var.cluster_name}-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.lbc_pod_identity_trust.json
  description        = "Pod Identity role for the AWS Load Balancer Controller. The Helm release is a later stage."
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "${var.cluster_name}-AWSLoadBalancerController"
  description = "Load Balancer Controller IAM policy. The v2.14.1 and v3.6.2 raw URLs were the same bytes on 2026-11-07."
  policy      = file("${path.module}/../policies/aws-load-balancer-controller-v2.14.1.json")
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

data "aws_iam_policy_document" "secrets_key" {
  count = var.encrypt_kubernetes_secrets ? 1 : 0

  statement {
    sid     = "AccountAdministratorsManageTheKey"
    effect  = "Allow"
    actions = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "ClusterRoleEncryptsSecrets"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:ListGrants",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cluster.arn]
    }

    resources = ["*"]
  }

  statement {
    sid     = "ClusterRoleCreatesGrantsForAwsResources"
    effect  = "Allow"
    actions = ["kms:CreateGrant"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cluster.arn]
    }

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "secrets" {
  count = var.encrypt_kubernetes_secrets ? 1 : 0

  description             = "Envelope encryption for Kubernetes secrets in ${var.cluster_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.secrets_key[0].json
}

resource "aws_kms_alias" "secrets" {
  count = var.encrypt_kubernetes_secrets ? 1 : 0

  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}
