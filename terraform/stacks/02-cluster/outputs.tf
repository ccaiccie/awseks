output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API endpoint. Private, public, or both, depending on the endpoint variables."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "cluster_service_cidr" {
  description = "Kubernetes ClusterIP range. These addresses are not VPC routes."
  value       = module.eks.cluster_service_cidr
}

output "oidc_provider_arn" {
  description = "IRSA provider. Workload Pod Identity does not use this ARN."
  value       = module.eks.oidc_provider_arn
}

output "cluster_iam_role_arn" {
  description = "Control plane role. Not a human, node, or workload identity."
  value       = module.eks.cluster_iam_role_arn
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "ebs_csi_pod_identity_role_arn" {
  description = "EBS CSI controller role. Distinct from the node role."
  value       = module.ebs_csi_pod_identity.iam_role_arn
}

output "managed_node_groups" {
  description = "Managed node group attributes, including each node IAM role ARN."
  value       = module.eks.eks_managed_node_groups
}

output "update_kubeconfig_command" {
  description = "Run this yourself after apply. Terraform does not execute it."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "pinned_addon_versions" {
  description = "Addon versions selected for this Kubernetes minor."
  value = merge(local.addon_versions, {
    aws-ebs-csi-driver     = var.ebs_csi_addon_version
    eks-pod-identity-agent = coalesce(var.pod_identity_agent_addon_version, "most_recent_at_apply")
  })
}
