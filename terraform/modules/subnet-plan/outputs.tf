output "private_subnets" {
  description = "Private worker subnet CIDRs, one per Availability Zone."
  value       = local.private_subnets
}

output "public_subnets" {
  description = "Public load-balancer subnet CIDRs, one per Availability Zone."
  value       = local.public_subnets
}
