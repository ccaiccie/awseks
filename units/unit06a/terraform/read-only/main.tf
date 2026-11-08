# Data-only configuration. There is deliberately NO resource block.
provider "aws" {
  profile             = var.aws_profile
  region              = var.aws_region
  allowed_account_ids = [var.expected_account_id]
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
data "aws_eks_cluster_versions" "standard" {
  version_status = "STANDARD_SUPPORT"
}
data "aws_eks_addon_version" "vpc_cni" {
  count              = var.kubernetes_version == null ? 0 : 1
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}
data "aws_ec2_instance_type" "node" {
  instance_type = var.instance_type
}
data "aws_ec2_instance_type_offerings" "node" {
  location_type = "availability-zone"
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}
data "aws_subnet" "existing" {
  for_each = var.existing_subnet_ids
  id       = each.value
}
locals {
  # EC2 limits, not a Kubernetes scheduler promise.
  classic_max_pods = data.aws_ec2_instance_type.node.maximum_network_interfaces * (data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface - 1) + 2
}
