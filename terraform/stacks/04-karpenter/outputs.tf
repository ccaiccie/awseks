output "enabled" {
  description = "False means this apply created no Karpenter resources."
  value       = local.karpenter_on
}

output "karpenter_role_arn" {
  value = local.karpenter_on ? module.karpenter.iam_role_arn : null
}

output "karpenter_node_role_arn" {
  description = "Instance role for nodes Karpenter launches. This is not the controller role."
  value       = local.karpenter_on ? module.karpenter.node_iam_role_arn : null
}

output "interruption_queue_name" {
  value = local.karpenter_on ? module.karpenter.queue_name : null
}
