output "address_plan" {
  description = "Illustrative design only; no subnets created."
  value = {
    vpc_cidr     = var.vpc_cidr
    service_cidr = var.service_cidr
    subnets      = local.subnets
  }
}
output "capacity_per_private_subnet" {
  value = {
    usable_ipv4        = local.usable_private_ipv4
    node_reservation   = local.node_ipv4_reservation
    other_reservations = local.other_reservations
    total_planned      = local.planned_ipv4
    remaining          = local.remaining_ipv4
    planned_percent    = local.planned_percent
    below_course_50pct = local.planned_percent <= 50
    classic_max_pods   = local.classic_max_pods
    mode               = "Illustrative secondary-IP mode; not a scheduler guarantee or prefix-delegation formula"
  }
}
