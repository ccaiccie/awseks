variable "region" {
  type        = string
  description = "AWS region for this lab. There is no default, so a plan cannot silently target the wrong region."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "region must look like a commercial AWS region such as us-west-2."
  }
}

variable "owner" {
  type        = string
  description = "Value of the Owner tag. Use a name or handle your account already uses for cost allocation."
  default     = "student"

  validation {
    condition     = length(var.owner) > 0 && length(var.owner) <= 64
    error_message = "owner must be 1 to 64 characters."
  }
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name owned by Terraform. Must stay on the awseks-tf- prefix so it cannot collide with the AWS CLI path."
  default     = "awseks-tf-lab"

  validation {
    condition     = can(regex("^awseks-tf-[a-z0-9-]{1,24}$", var.cluster_name))
    error_message = "cluster_name must match ^awseks-tf-[a-z0-9-]{1,24}$."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes minor version on standard support. Default 1.36 matches the class teaching baseline. 1.34, 1.35, and 1.37 remain accepted."
  default     = "1.36"

  validation {
    condition     = contains(["1.34", "1.35", "1.36", "1.37"], var.kubernetes_version)
    error_message = "kubernetes_version must be an EKS standard-support minor verified for this lab: 1.34, 1.35, 1.36, or 1.37. Extended-support minors are rejected because they change the price."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for the lab VPC. Must not overlap the Kubernetes service CIDR."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) <= 20
    error_message = "vpc_cidr must be a valid IPv4 CIDR of /20 or larger (a smaller prefix number)."
  }
}

variable "service_ipv4_cidr" {
  type        = string
  description = "Kubernetes Service CIDR (ClusterIP range). This is not a VPC subnet and must not overlap the VPC."
  default     = "172.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_ipv4_cidr, 0))
    error_message = "service_ipv4_cidr must be a valid IPv4 CIDR."
  }
}

variable "az_count" {
  type        = number
  description = "Number of Availability Zones. Minimum 2. Three costs more NAT gateways when nat_strategy is per_az."
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "nat_strategy" {
  type        = string
  description = "single: one NAT gateway (cheaper, egress dies with that AZ). per_az: one NAT per AZ. none: no NAT; interface VPC endpoints are required and are not free."
  default     = "single"

  validation {
    condition     = contains(["single", "per_az", "none"], var.nat_strategy)
    error_message = "nat_strategy must be single, per_az, or none."
  }
}

variable "enable_interface_endpoints" {
  type        = bool
  description = "Create interface VPC endpoints (ECR API, ECR DKR, EKS Auth, EC2, STS, Logs, ELB, Auto Scaling) in addition to the free S3 gateway endpoint. Forced on when nat_strategy is none."
  default     = false
}

variable "enable_public_endpoint" {
  type        = bool
  description = "Expose the Kubernetes API on the public endpoint. Private endpoint access stays enabled either way. Public access also requires public_access_cidrs and rejects 0.0.0.0/0."
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to call the public Kubernetes API. Required when enable_public_endpoint is true. 0.0.0.0/0 and documentation ranges are rejected."
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_access_cidrs : (
        can(cidrhost(cidr, 0)) &&
        cidr != "0.0.0.0/0" &&
        !startswith(cidr, "192.0.2.") &&
        !startswith(cidr, "198.51.100.") &&
        !startswith(cidr, "203.0.113.")
      )
    ])
    error_message = "Each public_access_cidrs entry must be a real CIDR, must not be 0.0.0.0/0, and must not be an RFC 5737 documentation address (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)."
  }
}

variable "api_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed through the additional security group to the private API on TCP 443. Empty uses the VPC CIDR. 0.0.0.0/0 is rejected."
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.api_ingress_cidrs : can(cidrhost(cidr, 0)) && cidr != "0.0.0.0/0"
    ])
    error_message = "api_ingress_cidrs entries must be CIDRs other than 0.0.0.0/0."
  }
}

variable "bootstrap_cluster_creator_admin" {
  type        = bool
  description = "Create an EKS access entry that grants the cluster creator AmazonEKSClusterAdminPolicy. Leave true unless you have already named another admin principal. This is the human admin identity, not the node role."
  default     = true
}

variable "extra_admin_principal_arn" {
  type        = string
  description = "Optional IAM role or user ARN that also receives cluster-admin Kubernetes access. Leave empty. Do not pass a wildcard."
  default     = ""

  validation {
    condition     = var.extra_admin_principal_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:(role|user)/.+$", var.extra_admin_principal_arn))
    error_message = "extra_admin_principal_arn must be empty or a concrete IAM role or user ARN."
  }
}

variable "viewer_principal_arn" {
  type        = string
  description = "Optional IAM role or user ARN that receives AmazonEKSViewPolicy at cluster scope."
  default     = ""

  validation {
    condition     = var.viewer_principal_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:(role|user)/.+$", var.viewer_principal_arn))
    error_message = "viewer_principal_arn must be empty or a concrete IAM role or user ARN."
  }
}

variable "deletion_protection" {
  type        = bool
  description = "When true, EKS rejects cluster deletion until you apply deletion_protection = false. Leave true for the lab."
  default     = true
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group. t3.medium is the smallest size this lab recommends once CoreDNS, VPC CNI, and the pod identity agent are scheduled."
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one instance type."
  }
}

variable "node_ami_type" {
  type        = string
  description = "Managed node group AMI type. AL2023 is the current standard Amazon Linux generation for EKS."
  default     = "AL2023_x86_64_STANDARD"

  validation {
    condition     = contains(["AL2023_x86_64_STANDARD", "AL2023_ARM_64_STANDARD"], var.node_ami_type)
    error_message = "node_ami_type must be AL2023_x86_64_STANDARD or AL2023_ARM_64_STANDARD. Match the instance family to the architecture."
  }
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND is the default. SPOT is an optional interruption lab, not the first cluster."
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  type        = number
  description = "Desired managed nodes. Use at least 2 so pods can spread across AZs."
  default     = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_disk_gib" {
  type        = number
  description = "Encrypted gp3 root volume size for each node."
  default     = 20

  validation {
    condition     = var.node_disk_gib >= 20 && var.node_disk_gib <= 100
    error_message = "node_disk_gib must stay between 20 and 100 for this lab."
  }
}

variable "cluster_log_types" {
  type        = list(string)
  description = "EKS control plane logs exported to CloudWatch. Empty by default because ingestion is billed. Allowed values: api, audit, authenticator, controllerManager, scheduler."
  default     = []

  validation {
    condition = alltrue([
      for item in var.cluster_log_types : contains(
        ["api", "audit", "authenticator", "controllerManager", "scheduler"],
        item
      )
    ])
    error_message = "cluster_log_types contains an unknown log type."
  }
}

variable "encrypt_kubernetes_secrets" {
  type        = bool
  description = "Create a KMS key and envelope-encrypt Kubernetes secrets. Off by default because the key has a monthly charge."
  default     = false
}

variable "enable_flow_logs" {
  type        = bool
  description = "Write VPC flow logs to CloudWatch. Off by default because ingestion is billed."
  default     = false
}

variable "addon_version_overrides" {
  type        = map(string)
  description = "Optional exact add-on versions that replace the documented pins. Use this only after describe-addon-versions shows the version is compatible."
  default     = {}
}

variable "vpc_cni_use_pod_identity" {
  type        = bool
  description = "Move AmazonEKS_CNI_Policy off the node role and onto a Pod Identity role for aws-node. Leave false on the first apply. Enable only on a later apply, after the pod identity agent is ACTIVE. See docs/iam.md."
  default     = false
}
