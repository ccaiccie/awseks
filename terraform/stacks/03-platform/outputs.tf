output "identity_demo_bucket" {
  description = "Private bucket used by lab 08. Null when the demo is disabled."
  value       = try(aws_s3_bucket.identity_demo[0].bucket, null)
}

output "lab_workload_role_arn" {
  description = "Pod Identity role for service account lab-identity/lab-pod-identity."
  value       = try(aws_iam_role.lab_workload[0].arn, null)
}

output "lab_irsa_role_arn" {
  description = "IRSA role for service account lab-identity/lab-irsa. ListBucket only."
  value       = try(aws_iam_role.lab_irsa[0].arn, null)
}

output "aws_load_balancer_controller_role_arn" {
  value = try(module.aws_lb_controller_pod_identity.iam_role_arn, null)
}

output "efs_file_system_id" {
  description = "Null unless enable_efs and efs_confirmation are both set."
  value       = try(aws_efs_file_system.lab[0].id, null)
}
