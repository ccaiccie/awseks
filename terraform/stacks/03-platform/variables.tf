variable "region" {
  type = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must look like us-west-2."
  }
}

variable "cluster_name" {
  description = "Name of the cluster created by stack 02. This stack does not create a cluster."
  type        = string
  default     = "eks-lab"
}

variable "enable_metrics_server" {
  description = "Install the metrics-server Helm chart so kubectl top and HPA work."
  type        = bool
  default     = true
}

variable "metrics_server_chart_version" {
  description = "kubernetes-sigs metrics-server chart. 3.14.0 publishes image v0.9.0."
  type        = string
  default     = "3.14.0"
}

variable "enable_aws_load_balancer_controller" {
  description = "Install the AWS Load Balancer Controller. It does not create a load balancer until a lab Service or Ingress exists."
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Chart version. 3.6.2 is the controller release reviewed on 2026-11-07. Gateway API support is controller-specific; see lab 18."
  type        = string
  default     = "3.6.2"
}

variable "enable_identity_demo" {
  description = "Create the lab S3 bucket, Pod Identity role, and IRSA role used by lab 08."
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Create an encrypted EFS file system, mount targets, and the EFS CSI addon. This is an hourly and per-AZ cost."
  type        = bool
  default     = false
}

variable "efs_confirmation" {
  description = "Set to enable-efs together with enable_efs=true."
  type        = string
  default     = ""
}

variable "efs_csi_addon_version" {
  description = "Optional pin. Null uses the EKS default addon version at apply time. Confirm with describe-addon-versions."
  type        = string
  default     = null
}
