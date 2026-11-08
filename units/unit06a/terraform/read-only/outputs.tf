output "identity" {
  description = "Account/ARN metadata; do not publish your local state or outputs."
  value = {
    account_id = data.aws_caller_identity.current.account_id
    arn        = data.aws_caller_identity.current.arn
    region     = data.aws_region.current.region
  }
}
output "eks_standard_versions" {
  value = data.aws_eks_cluster_versions.standard.cluster_versions
}
output "vpc_cni_latest_compatible_version" {
  description = "Optional latest compatible version, NOT a guarantee of suitability for your architecture/configuration."
  value       = try(data.aws_eks_addon_version.vpc_cni[0].version, null)
}
output "availability_zones" {
  value = {
    names = data.aws_availability_zones.available.names
    ids   = data.aws_availability_zones.available.zone_ids
  }
}
output "instance_type_observation" {
  value = {
    type             = var.instance_type
    offered_in       = data.aws_ec2_instance_type_offerings.node.locations
    maximum_enis     = data.aws_ec2_instance_type.node.maximum_network_interfaces
    ipv4_per_eni     = data.aws_ec2_instance_type.node.maximum_ipv4_addresses_per_interface
    classic_max_pods = local.classic_max_pods
    warning          = "Offered does NOT prove spare capacity; no launch was attempted. Secondary-IP mode only."
  }
}
output "existing_subnets" {
  value = {
    for id, subnet in data.aws_subnet.existing : id => {
      cidr      = subnet.cidr_block
      az        = subnet.availability_zone
      vpc       = subnet.vpc_id
      free_ipv4 = subnet.available_ip_address_count
    }
  }
  description = "Point-in-time subnet address observations, not reserved future capacity."
}
