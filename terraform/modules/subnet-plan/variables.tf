variable "vpc_cidr" {
  description = "IPv4 CIDR for the dedicated practice VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/(16|17|18)$", var.vpc_cidr))
    error_message = "vpc_cidr must be an IPv4 CIDR from /16 to /18 so each private subnet can be a /19-/21."
  }
}

variable "az_count" {
  description = "Number of Availability Zones. Minimum 2."
  type        = number

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}
