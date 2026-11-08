# OPTIONAL existing infrastructure observations. Empty sets skip these lookups.
# IDs/names must come from authorized CLI readouts in this account and Region.
variable "existing_vpc_ids" {
  type    = set(string)
  default = []
}
variable "existing_route_table_ids" {
  type    = set(string)
  default = []
}
variable "existing_nat_gateway_ids" {
  type    = set(string)
  default = []
}
variable "existing_internet_gateway_ids" {
  type    = set(string)
  default = []
}
variable "existing_cluster_names" {
  type    = set(string)
  default = []
}
data "aws_vpc" "existing" {
  for_each = var.existing_vpc_ids
  id       = each.value
}
data "aws_route_table" "existing" {
  for_each       = var.existing_route_table_ids
  route_table_id = each.value
}
data "aws_nat_gateway" "existing" {
  for_each = var.existing_nat_gateway_ids
  id       = each.value
}
data "aws_internet_gateway" "existing" {
  for_each            = var.existing_internet_gateway_ids
  internet_gateway_id = each.value
}
data "aws_eks_cluster" "existing" {
  for_each = var.existing_cluster_names
  name     = each.value
}
output "vpc_observations" {
  value = { for id, v in data.aws_vpc.existing : id => {
    cidr             = v.cidr_block
    all_cidrs        = v.cidr_block_associations
    dns_support      = v.enable_dns_support
    dns_hostnames    = v.enable_dns_hostnames
    main_route_table = v.main_route_table_id
  } }
}
output "route_table_observations" {
  description = "Real associated subnet/table/route observations; CLI is still needed for per-route State and packet LPM reasoning."
  value = { for id, r in data.aws_route_table.existing : id => {
    vpc          = r.vpc_id
    associations = r.associations
    routes       = r.routes
  } }
}
output "nat_observations" {
  value = { for id, n in data.aws_nat_gateway.existing : id => {
    state        = n.state
    vpc          = n.vpc_id
    subnet       = n.subnet_id
    connectivity = n.connectivity_type
    private_ip   = n.private_ip
    public_ip    = n.public_ip
  } }
}
output "internet_gateway_observations" {
  value = { for id, g in data.aws_internet_gateway.existing : id => {
    attachments = g.attachments
  } }
}
output "cluster_observations" {
  description = "Private account metadata; no authentication token or credentials are requested."
  value = { for name, c in data.aws_eks_cluster.existing : name => {
    api_endpoint    = c.endpoint
    authentication  = c.access_config
    version         = c.version
    status          = c.status
    vpc             = c.vpc_config
    service_network = c.kubernetes_network_config
    support         = c.upgrade_policy
    enabled_logs    = c.enabled_cluster_log_types
  } }
}
