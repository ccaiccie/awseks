variable "vpc_cidr" {
  description = "Illustrative IPv4 /16; use only an approved non-overlapping RFC1918 range."
  type        = string
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && can(regex("/16$", var.vpc_cidr))
    error_message = "This teaching calculator requires a valid IPv4 /16."
  }
}
variable "service_cidr" {
  description = "Illustrative Kubernetes virtual Service range, not a VPC subnet. Verify overlap with scripts/network_checks.py."
  type        = string
  default     = "172.20.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.service_cidr))
    error_message = "Supply a valid IPv4 CIDR, then check EKS size/private-range/overlap requirements with Python."
  }
}
variable "nodes_per_az" {
  description = "Maximum steady nodes in each AZ, not desired cluster total."
  type        = number
  default     = 2
  validation {
    condition     = var.nodes_per_az >= 0 && floor(var.nodes_per_az) == var.nodes_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "surge_per_az" {
  description = "Additional nodes during replacement, illustrative reservation."
  type        = number
  default     = 2
  validation {
    condition     = var.surge_per_az >= 0 && floor(var.surge_per_az) == var.surge_per_az
    error_message = "Use a non-negative integer."
  }
}
variable "enis_per_node" {
  description = "Illustrative m6i.large limit; read actual EC2 type limits before using a different type."
  type        = number
  default     = 3
  validation {
    condition     = var.enis_per_node >= 1 && floor(var.enis_per_node) == var.enis_per_node
    error_message = "Use a positive integer."
  }
}
variable "ipv4_per_eni" {
  description = "Includes primary IPv4; this calculator models secondary-IP mode, NOT prefix delegation."
  type        = number
  default     = 10
  validation {
    condition     = var.ipv4_per_eni >= 1 && floor(var.ipv4_per_eni) == var.ipv4_per_eni
    error_message = "Use a positive integer."
  }
}
