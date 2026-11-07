locals {
  tags = {
    Project    = "awseks-practice"
    ManagedBy  = "terraform"
    Stack      = "02-cluster"
    NamePrefix = var.name
    CostCenter = "eks-networking-masterclass"
  }

  # Retrieved 2026-11-07 from the AWS "latest addon version" tables.
  # vpc-cni:  https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
  # coredns:  https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  # kube-proxy: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  documented_addon_versions = {
    "1.34" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      coredns    = "v1.13.2-eksbuild.62"
      kube-proxy = "v1.34.6-eksbuild.62"
    }
    "1.35" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      coredns    = "v1.14.7-eksbuild.22"
      kube-proxy = "v1.35.3-eksbuild.62"
    }
    "1.36" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      coredns    = "v1.14.7-eksbuild.22"
      kube-proxy = "v1.36.0-eksbuild.58"
    }
    "1.37" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      coredns    = "v1.14.7-eksbuild.22"
      kube-proxy = "v1.37.0-eksbuild.32"
    }
  }

  addon_versions = merge(
    local.documented_addon_versions[var.kubernetes_version],
    var.addon_version_overrides,
  )

  vpc_id             = var.use_network_remote_state ? data.terraform_remote_state.network[0].outputs.vpc_id : var.vpc_id
  vpc_cidr           = var.use_network_remote_state ? data.terraform_remote_state.network[0].outputs.vpc_cidr : var.vpc_cidr
  private_subnet_ids = var.use_network_remote_state ? data.terraform_remote_state.network[0].outputs.private_subnet_ids : var.private_subnet_ids

  lab_node_group = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = var.node_instance_types
    capacity_type  = "ON_DEMAND"
    min_size       = var.node_min_size
    max_size       = var.node_max_size
    desired_size   = var.node_desired_size

    iam_role_name            = "${var.name}-node"
    iam_role_use_name_prefix = false
    iam_role_path            = "/awseks-practice/"
    # The node role keeps AmazonEKS_CNI_Policy so the first nodes can attach
    # ENIs even while you study a separate workload Pod Identity role.
    iam_role_attach_cni_policy = true

    labels = {
      "awseks.practice/nodegroup" = "lab"
    }

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
    }

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 20
          volume_type           = "gp3"
          encrypted             = true
          delete_on_termination = true
        }
      }
    }

    update_config = {
      max_unavailable = 1
    }

    enable_monitoring = false
  }

  spot_node_group = var.enable_spot_node_group ? {
    spot = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types
      capacity_type  = "SPOT"
      min_size       = 0
      max_size       = 2
      desired_size   = 0

      iam_role_name              = "${var.name}-spot-node"
      iam_role_use_name_prefix   = false
      iam_role_path              = "/awseks-practice/"
      iam_role_attach_cni_policy = true

      labels = {
        "awseks.practice/nodegroup" = "spot"
      }

      taints = {
        spot = {
          key    = "awseks.practice/capacity"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      enable_monitoring = false
    }
  } : {}
}

module "guardrails" {
  source = "../../modules/guardrails"

  name = var.name

  check_endpoint               = true
  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  check_admin_principals       = true
  admin_principal_arns         = var.admin_principal_arns
  check_nodes                  = true
  node_instance_types          = var.node_instance_types
  allow_expensive_nodes        = var.allow_expensive_nodes
  node_min_size                = var.node_min_size
  node_desired_size            = var.node_desired_size
  node_max_size                = var.node_max_size
  allow_large_node_count       = var.allow_large_node_count
  check_kubernetes_version     = true
  kubernetes_version           = var.kubernetes_version
}

data "terraform_remote_state" "network" {
  count = var.use_network_remote_state ? 1 : 0

  backend = "local"

  config = {
    path = var.network_state_path
  }
}

module "service_cidr_overlap" {
  source = "../../modules/cidr-overlap"

  left  = local.vpc_cidr == null ? "10.0.0.0/16" : local.vpc_cidr
  right = var.service_ipv4_cidr
}

resource "terraform_data" "network_and_endpoint_guard" {
  lifecycle {
    precondition {
      condition     = var.endpoint_private_access || var.endpoint_public_access
      error_message = "Enable the private endpoint, the public endpoint, or both. Both off removes every API path."
    }
    precondition {
      condition     = local.vpc_id != null && local.vpc_cidr != null && length(local.private_subnet_ids) >= 2
      error_message = "The cluster needs the VPC id, VPC CIDR, and at least two private subnet ids from stack 01-network."
    }
    precondition {
      condition     = !module.service_cidr_overlap.overlaps
      error_message = "service_ipv4_cidr overlaps the VPC CIDR. Service IPs are cluster-local and must not be VPC routes."
    }
  }
}

module "ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "2.10.0"

  name            = "${var.name}-ebs-csi"
  use_name_prefix = false
  path            = "/awseks-practice/"

  attach_aws_ebs_csi_policy = true

  associations = {}

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = module.guardrails.name
  kubernetes_version = var.kubernetes_version

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access ? var.endpoint_public_access_cidrs : ["203.0.113.1/32"]

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = false

  ip_family         = "ipv4"
  service_ipv4_cidr = var.service_ipv4_cidr

  upgrade_policy = {
    support_type = "STANDARD"
  }

  deletion_protection = var.cluster_deletion_protection

  enabled_log_types = var.enable_control_plane_logs ? ["api", "audit", "authenticator"] : []

  create_cloudwatch_log_group            = var.enable_control_plane_logs
  cloudwatch_log_group_retention_in_days = 1

  create_kms_key                  = true
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  create_iam_role          = true
  iam_role_name            = "${var.name}-cluster"
  iam_role_use_name_prefix = false
  iam_role_path            = "/awseks-practice/"
  enable_irsa              = true

  # Standard managed node groups only. These stay null/false so Auto Mode
  # IAM and node pools are not created.
  compute_config                 = null
  create_auto_mode_iam_resources = false
  create_node_iam_role           = false

  access_entries = {
    for index, arn in var.admin_principal_arns : "admin-${index}" => {
      principal_arn = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = merge(
    {
      lab = local.lab_node_group
    },
    local.spot_node_group,
  )

  addons = {
    vpc-cni = {
      before_compute              = true
      addon_version               = local.addon_versions["vpc-cni"]
      most_recent                 = false
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = var.enable_network_policy ? jsonencode({
        enableNetworkPolicy = "true"
      }) : null
    }
    kube-proxy = {
      before_compute              = true
      addon_version               = local.addon_versions["kube-proxy"]
      most_recent                 = false
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      before_compute              = true
      addon_version               = var.pod_identity_agent_addon_version
      most_recent                 = var.pod_identity_agent_addon_version == null
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      before_compute              = false
      addon_version               = local.addon_versions["coredns"]
      most_recent                 = false
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      before_compute              = false
      addon_version               = var.ebs_csi_addon_version
      most_recent                 = false
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      pod_identity_association = [
        {
          role_arn        = module.ebs_csi_pod_identity.iam_role_arn
          service_account = "ebs-csi-controller-sa"
        }
      ]
    }
  }

  tags = local.tags

  depends_on = [terraform_data.network_and_endpoint_guard]
}
