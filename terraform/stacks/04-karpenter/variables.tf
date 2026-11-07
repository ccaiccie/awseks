variable "region" {
  type = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must look like us-west-2."
  }
}

variable "cluster_name" {
  type    = string
  default = "eks-lab"
}

variable "enable_karpenter" {
  description = "Optional track. Default false creates no Karpenter resources."
  type        = bool
  default     = false
}

variable "karpenter_confirmation" {
  description = "Set to enable-karpenter together with enable_karpenter=true."
  type        = string
  default     = ""
}

variable "karpenter_chart_version" {
  description = "Pinned to 1.15.1 from the Karpenter compatibility page retrieved 2026-11-07. Kubernetes 1.35 needs >= 1.9, 1.36 needs >= 1.13, and 1.37 lists 1.15.x."
  type        = string
  default     = "1.15.1"
}

variable "allow_untested_karpenter_version" {
  description = "Escape hatch if you intentionally move off chart 1.15.1 after checking the compatibility matrix."
  type        = bool
  default     = false
}
