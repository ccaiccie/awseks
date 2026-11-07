variable "name" {
  description = "Short prefix for every practice resource. Used in names and the Project tag."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,16}$", var.name))
    error_message = "name must be 2-17 characters, start with a letter, and use only lowercase letters, digits, and hyphens."
  }
}

variable "check_endpoint" {
  description = "When true, enforce the private/public API endpoint rules."
  type        = bool
  default     = false
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "endpoint_public_access_cidrs" {
  type    = list(string)
  default = []

  validation {
    condition = !var.check_endpoint || !var.endpoint_public_access || (
      length(var.endpoint_public_access_cidrs) > 0 &&
      alltrue([
        for cidr in var.endpoint_public_access_cidrs : (
          can(cidrhost(cidr, 0)) &&
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/(2[4-9]|3[0-2])$", cidr))
        )
      ])
    )
    error_message = "Public API access requires one or more IPv4 CIDRs of /24 or smaller and rejects 0.0.0.0/0. Use your operator address, for example 203.0.113.10/32."
  }
}

variable "check_admin_principals" {
  type    = bool
  default = false
}

variable "admin_principal_arns" {
  type    = list(string)
  default = []

  validation {
    condition = !var.check_admin_principals || (
      length(var.admin_principal_arns) > 0 &&
      alltrue([
        for arn in var.admin_principal_arns :
        can(regex("^arn:aws[a-zA-Z-]*:iam::[0-9]{12}:(role|user)/.+$", arn)) &&
        !can(regex(":root$", arn)) &&
        !can(regex(":iam::[0-9]{12}:user/Administrator$", arn))
      ])
    )
    error_message = "admin_principal_arns must list IAM user or role ARNs. Account root is rejected. Do not pass a local account id; copy the ARN from aws sts get-caller-identity."
  }
}

variable "check_nodes" {
  type    = bool
  default = false
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "allow_expensive_nodes" {
  type    = bool
  default = false

  validation {
    condition = !var.check_nodes || var.allow_expensive_nodes || alltrue([
      for instance_type in var.node_instance_types :
      can(regex("^(t3|t3a|t4g)\\.(small|medium|large)$", instance_type))
    ])
    error_message = "The lab allow-list is t3, t3a, and t4g in small, medium, or large. t3.micro is below the system-pod minimum. Set allow_expensive_nodes=true only after reading the cost page."
  }
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "allow_large_node_count" {
  type    = bool
  default = false

  validation {
    condition = !var.check_nodes || (
      var.node_min_size >= 1 &&
      var.node_desired_size >= var.node_min_size &&
      var.node_max_size >= var.node_desired_size &&
      var.node_desired_size >= 2 &&
      (var.allow_large_node_count || var.node_max_size <= 4)
    )
    error_message = "Use at least two desired nodes so cross-node labs work, keep max_size <= 4, and keep min <= desired <= max. Set allow_large_node_count=true to raise the cap."
  }
}

variable "check_kubernetes_version" {
  type    = bool
  default = false
}

variable "kubernetes_version" {
  type    = string
  default = "1.35"

  validation {
    condition     = !var.check_kubernetes_version || contains(["1.34", "1.35", "1.36", "1.37"], var.kubernetes_version)
    error_message = "kubernetes_version must be 1.34, 1.35, 1.36, or 1.37. 1.34 leaves EKS standard support on 2026-12-02. This track is standard EKS, not Auto Mode."
  }
}

variable "check_confirmation" {
  type    = bool
  default = false
}

variable "confirmation_enabled" {
  type    = bool
  default = false
}

variable "confirmation_value" {
  type    = string
  default = ""
}

variable "confirmation_expected" {
  type    = string
  default = ""

  validation {
    condition     = !var.check_confirmation || !var.confirmation_enabled || var.confirmation_value == var.confirmation_expected
    error_message = "This optional resource stays off until confirmation_value equals the expected opt-in string documented for that stack."
  }
}
