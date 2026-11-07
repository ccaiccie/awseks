variable "region" {
  description = "AWS Region for this practice VPC. Confirm prices for this Region before apply."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must look like us-west-2."
  }
}

variable "name" {
  description = "Short name prefix shared with the cluster stack. Resources are tagged Project=awseks-practice."
  type        = string
  default     = "eks-lab"
}

variable "vpc_cidr" {
  description = "Dedicated IPv4 CIDR. Must not overlap other networks you peer or VPN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Availability Zones to use. Workers and public LB subnets are created in each."
  type        = number
  default     = 2
}

variable "availability_zone_names" {
  description = "Optional explicit AZ names. Empty uses the first az_count available AZs."
  type        = list(string)
  default     = []
}

variable "nat_gateway_per_az" {
  description = "False (default) builds one NAT gateway, which is cheaper and is a single egress failure domain. True builds one NAT gateway per AZ."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Publish VPC flow logs to CloudWatch. Default false because ingestion is billed."
  type        = bool
  default     = false
}

variable "enable_interface_endpoints" {
  description = "Create interface VPC endpoints for private AWS API access. Default false."
  type        = bool
  default     = false
}

variable "interface_endpoint_confirmation" {
  description = "Must be enable-interface-endpoints when enable_interface_endpoints is true."
  type        = string
  default     = ""
}

variable "interface_endpoint_services" {
  description = "Suffixes of interface endpoint service names, for example ecr.api."
  type        = list(string)
  default = [
    "ecr.api",
    "ecr.dkr",
    "ec2",
    "sts",
    "logs",
    "eks",
    "eks-auth",
  ]
}
