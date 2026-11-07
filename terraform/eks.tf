resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_cluster_creator_admin
  }

  # Managed add-ons in addons.tf are the only copy of vpc-cni, kube-proxy, and CoreDNS.
  # Leaving the self-managed copies on would race with those add-ons in the same apply.
  bootstrap_self_managed_addons = false
  deletion_protection           = var.deletion_protection

  upgrade_policy {
    support_type = "STANDARD"
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.service_ipv4_cidr
  }

  vpc_config {
    subnet_ids              = [for subnet in aws_subnet.private : subnet.id]
    security_group_ids      = [aws_security_group.api_from_vpc.id]
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_endpoint
    public_access_cidrs     = var.enable_public_endpoint ? var.public_access_cidrs : null
  }

  enabled_cluster_log_types = var.cluster_log_types

  dynamic "encryption_config" {
    for_each = var.encrypt_kubernetes_secrets ? [1] : []

    content {
      resources = ["secrets"]

      provider {
        key_arn = aws_kms_key.secrets[0].arn
      }
    }
  }

  tags = {
    Name = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_vpc_resource_controller,
  ]

  lifecycle {
    precondition {
      condition     = !var.enable_public_endpoint || (length(var.public_access_cidrs) > 0 && !contains(var.public_access_cidrs, "0.0.0.0/0"))
      error_message = "Public API access requires an explicit CIDR allow list and rejects 0.0.0.0/0."
    }

    precondition {
      condition     = var.nat_strategy != "none" || length(aws_vpc_endpoint.interface) == length(local.interface_services)
      error_message = "nat_strategy none has no default route. Interface endpoints for ECR, EKS Auth, and the other AWS APIs must exist or nodes cannot pull images or call EKS Auth."
    }
  }
}

resource "aws_launch_template" "nodes" {
  name_prefix            = "${var.cluster_name}-nodes-"
  update_default_version = true
  description            = "IMDSv2 hop limit 1, encrypted gp3 root, no SSH key."

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_gib
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${var.cluster_name}-node" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.tags, { Name = "${var.cluster_name}-node" })
  }

  tags = {
    Name = "${var.cluster_name}-nodes"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-managed"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for subnet in aws_subnet.private : subnet.id]

  ami_type       = var.node_ami_type
  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  labels = {
    "awseks.practice/nodegroup" = "default"
  }

  tags = {
    Name = "${var.cluster_name}-managed"
  }

  # Do not depend on the VPC CNI add-on. The node group and that add-on are created
  # together after the cluster is ACTIVE. Chaining them deadlocks: nodes stay
  # NotReady until aws-node runs, and the add-on cannot become ACTIVE before a node exists.
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ecr_pull,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.vpc_cni,
  ]

  lifecycle {
    precondition {
      condition     = !(var.node_ami_type == "AL2023_ARM_64_STANDARD" && anytrue([for instance_type in var.node_instance_types : startswith(instance_type, "t3.") || startswith(instance_type, "m5.") || startswith(instance_type, "c5.")]))
      error_message = "AL2023_ARM_64_STANDARD needs Graviton instance types such as t4g or m7g. t3, m5, and c5 are x86."
    }
  }

  timeouts {
    create = "40m"
    update = "40m"
    delete = "40m"
  }
}

resource "aws_eks_access_entry" "extra_admin" {
  count = var.extra_admin_principal_arn == "" ? 0 : 1

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.extra_admin_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "extra_admin" {
  count = var.extra_admin_principal_arn == "" ? 0 : 1

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.extra_admin_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.extra_admin]
}

resource "aws_eks_access_entry" "viewer" {
  count = var.viewer_principal_arn == "" ? 0 : 1

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.viewer_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "viewer" {
  count = var.viewer_principal_arn == "" ? 0 : 1

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.viewer_principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.viewer]
}
