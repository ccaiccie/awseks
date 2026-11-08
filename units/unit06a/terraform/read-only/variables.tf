variable "aws_profile" {
  description = "Name of YOUR existing temporary-credential profile, never an access key."
  type        = string
  validation {
    condition     = length(trimspace(var.aws_profile)) > 0
    error_message = "Supply your named profile."
  }
}
variable "aws_region" {
  description = "Your approved AWS Region, for example us-west-2."
  type        = string
}
variable "expected_account_id" {
  description = "Your approved twelve-digit AWS account ID. Provider refuses a different account."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Supply exactly twelve digits."
  }
}
variable "instance_type" {
  description = "Read characteristics/offering only, never launch."
  type        = string
  default     = "m6i.large"
}
variable "kubernetes_version" {
  description = "Optional exact version chosen from your standard-support readout. null skips the add-on query."
  type        = string
  default     = null
}
variable "existing_subnet_ids" {
  description = "Optional existing subnet IDs in this account/Region. Leave empty before Unit 6B."
  type        = set(string)
  default     = []
}
