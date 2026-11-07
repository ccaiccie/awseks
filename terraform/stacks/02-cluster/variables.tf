variable "region" {
  type = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must look like us-west-2."
  }
}

variable "name" {
  description = "Cluster name. Must match the network stack name prefix."
  type        = string
  default     = "eks-lab"
}

variable "kubernetes_version" {
  description = "Standard-support EKS minor version. Default 1.35. Avoid 1.34 after 2026-12-02 because extended support is $0.60 per cluster-hour."
  type        = string
  default     = "1.35"
}

variable "use_network_remote_state" {
  description = "Read VPC outputs from the 01-network local state file."
  type        = bool
  default     = true
}

variable "network_state_path" {
  description = "Path to the 01-network state file when use_network_remote_state is true."
  type        = string
  default     = "../01-network/terraform.tfstate"
}

variable "vpc_id" {
  description = "Used only when use_network_remote_state is false."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "Used only when use_network_remote_state is false. Must not overlap service_ipv4_cidr."
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  description = "Private worker subnet ids. Used only when use_network_remote_state is false."
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Keep the private API endpoint enabled. Default true."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Public API endpoint. Default false. Opt in with an explicit CIDR allowlist."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "IPv4 CIDRs allowed to call the public API. Each prefix must be /24 or smaller. A world-open prefix is rejected."
  type        = list(string)
  default     = []
}

variable "admin_principal_arns" {
  description = "IAM user or role ARNs that receive AmazonEKSClusterAdminPolicy through EKS access entries."
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "ClusterIP range. Not routed in the VPC. Must not overlap the VPC CIDR."
  type        = string
  default     = "172.20.0.0/16"
}

variable "node_instance_types" {
  description = "Managed node group instance types. Default t3.medium."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "allow_expensive_nodes" {
  type    = bool
  default = false
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
}

variable "enable_spot_node_group" {
  description = "Create a second managed node group with desired size 0 and a spot taint. It does not launch instances until you scale it."
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "Turn on the VPC CNI network policy agent. Default false until lab 06."
  type        = bool
  default     = false
}

variable "enable_control_plane_logs" {
  description = "Send api, audit, and authenticator logs to CloudWatch. Default false."
  type        = bool
  default     = false
}

variable "cluster_deletion_protection" {
  description = "When true, terraform destroy of the cluster fails until you set this back to false and apply."
  type        = bool
  default     = false
}

variable "ebs_csi_addon_version" {
  description = "EBS CSI addon version. Re-check with aws eks describe-addon-versions before apply."
  type        = string
  default     = "v1.67.2-eksbuild.1"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+-eksbuild\\.[0-9]+$", var.ebs_csi_addon_version))
    error_message = "ebs_csi_addon_version must look like v1.67.2-eksbuild.1."
  }
}

variable "pod_identity_agent_addon_version" {
  description = "Pin the Pod Identity agent addon. Null resolves most_recent at apply time because AWS does not publish a single table equivalent to kube-proxy. Run scripts/check-addon-versions.sh and pin the result."
  type        = string
  default     = null

  validation {
    condition = (
      var.pod_identity_agent_addon_version == null ||
      can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+-eksbuild\\.[0-9]+$", var.pod_identity_agent_addon_version))
    )
    error_message = "pod_identity_agent_addon_version must be null or look like v1.3.10-eksbuild.2."
  }
}

variable "addon_version_overrides" {
  description = "Optional map of addon name to version. Keys: vpc-cni, coredns, kube-proxy."
  type        = map(string)
  default     = {}
}
