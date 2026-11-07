output "vpc_id" {
  description = "Practice VPC id."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Practice VPC CIDR."
  value       = var.vpc_cidr
}

output "availability_zones" {
  description = "Availability Zones used by this VPC."
  value       = local.azs
}

output "private_subnet_ids" {
  description = "Private worker subnet ids, in AZ order."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public load-balancer subnet ids, in AZ order."
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "Route tables for private worker subnets."
  value       = module.vpc.private_route_table_ids
}

output "nat_gateway_ids" {
  description = "NAT gateways. One entry in the default single-NAT layout."
  value       = module.vpc.natgw_ids
}

output "s3_gateway_endpoint_id" {
  description = "Free S3 gateway endpoint associated with the private route tables."
  value       = aws_vpc_endpoint.s3.id
}

output "interface_endpoint_ids" {
  description = "Interface endpoint ids. Empty unless the cost opt-in is set."
  value       = { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.id }
}

output "nat_layout" {
  description = "Which egress layout this apply selected."
  value       = var.nat_gateway_per_az ? "one-nat-per-az" : "single-nat"
}
