# Pure calculations: no provider, AWS credentials or managed resources.
locals {
  subnets = {
    public_a  = cidrsubnet(var.vpc_cidr, 8, 0)
    public_b  = cidrsubnet(var.vpc_cidr, 8, 1)
    private_a = cidrsubnet(var.vpc_cidr, 4, 1)
    private_b = cidrsubnet(var.vpc_cidr, 4, 2)
  }
  usable_private_ipv4 = pow(2, 32 - 20) - 5
  other_reservations = {
    cluster_enis         = 4
    upgrade_cluster_enis = 4
    alb_headroom         = 8
    nlb_address          = 1
    endpoint_enis        = 6
  }
  node_ipv4_reservation = (var.nodes_per_az + var.surge_per_az) * var.enis_per_node * var.ipv4_per_eni
  planned_ipv4          = local.node_ipv4_reservation + sum(values(local.other_reservations))
  remaining_ipv4        = local.usable_private_ipv4 - local.planned_ipv4
  classic_max_pods      = var.enis_per_node * (var.ipv4_per_eni - 1) + 2
  planned_percent       = 100 * local.planned_ipv4 / local.usable_private_ipv4
}
