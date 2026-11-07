locals {
  tags = {
    Project     = "awseks-practice"
    Provisioner = "terraform"
    Owner       = var.owner
    Cluster     = var.cluster_name
  }

  # Versions copied from the Amazon EKS user guide tables fetched on 2026-11-07.
  # vpc-cni, kube-proxy, and CoreDNS publish a per-minor table. Pod Identity Agent
  # and the EBS CSI driver do not; those two are resolved from the EKS API at plan time.
  documented_addon_versions = {
    "1.34" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      kube-proxy = "v1.34.6-eksbuild.62"
      coredns    = "v1.13.2-eksbuild.62"
    }
    "1.35" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      kube-proxy = "v1.35.3-eksbuild.62"
      coredns    = "v1.14.7-eksbuild.22"
    }
    "1.36" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      kube-proxy = "v1.36.0-eksbuild.58"
      coredns    = "v1.14.7-eksbuild.22"
    }
    "1.37" = {
      vpc-cni    = "v1.23.2-eksbuild.8"
      kube-proxy = "v1.37.0-eksbuild.32"
      coredns    = "v1.14.7-eksbuild.22"
    }
  }

  documented_for_selected_minor = lookup(local.documented_addon_versions, var.kubernetes_version, {})
  discovered_networking_addons = {
    vpc-cni    = data.aws_eks_addon_version.vpc_cni.version
    kube-proxy = data.aws_eks_addon_version.kube_proxy.version
    coredns    = data.aws_eks_addon_version.coredns.version
  }
  # A dated pin from docs/versions.md overrides discovery only for minors listed there.
  # Any other minor uses the default compatible version from the EKS API.
  pinned_addons = merge(
    local.discovered_networking_addons,
    local.documented_for_selected_minor,
    { for key, value in var.addon_version_overrides : key => value if value != "" }
  )

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnet_cidrs  = [for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, index)]
  private_subnet_cidrs = [for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, index + 10)]

  nat_gateway_count           = var.nat_strategy == "per_az" ? var.az_count : (var.nat_strategy == "single" ? 1 : 0)
  interface_endpoints_enabled = var.nat_strategy == "none" || var.enable_interface_endpoints

  interface_services = [
    "ecr.api",
    "ecr.dkr",
    "eks-auth",
    "ec2",
    "sts",
    "logs",
    "elasticloadbalancing",
    "autoscaling",
  ]

  api_ingress_cidrs = length(var.api_ingress_cidrs) == 0 ? [var.vpc_cidr] : var.api_ingress_cidrs

  private_route_table_ids = var.nat_strategy == "per_az" ? [for table in aws_route_table.private_per_az : table.id] : [aws_route_table.private_shared[0].id]
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

check "enough_availability_zones" {
  assert {
    condition     = length(data.aws_availability_zones.available.names) >= var.az_count
    error_message = "The selected region does not have enough opted-in Availability Zones for az_count."
  }
}

check "service_cidr_does_not_overlap_vpc" {
  assert {
    condition     = var.vpc_cidr != var.service_ipv4_cidr
    error_message = "vpc_cidr and service_ipv4_cidr must be different ranges. The service CIDR is routed by kube-proxy, not by the VPC route table."
  }
}

check "public_endpoint_has_allowlist" {
  assert {
    condition     = !var.enable_public_endpoint || length(var.public_access_cidrs) > 0
    error_message = "enable_public_endpoint is true, so public_access_cidrs must contain your client CIDR. This lab does not default the public API to 0.0.0.0/0."
  }
}

check "creator_or_named_admin" {
  assert {
    condition     = var.bootstrap_cluster_creator_admin || var.extra_admin_principal_arn != ""
    error_message = "Refusing to plan a cluster with no human administrator. Enable bootstrap_cluster_creator_admin or set extra_admin_principal_arn."
  }
}

check "node_capacity_bounds" {
  assert {
    condition     = var.node_min_size >= 1 && var.node_min_size <= var.node_desired_size && var.node_desired_size <= var.node_max_size && var.node_max_size <= 6
    error_message = "Require 1 <= node_min_size <= node_desired_size <= node_max_size <= 6 so the lab cannot scale an unbounded group."
  }
}
