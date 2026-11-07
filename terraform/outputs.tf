output "region" {
  value = var.region
}

output "cluster_name" {
  description = "Terraform-owned cluster name. Do not point the AWS CLI path at this name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  value = aws_eks_cluster.this.version
}

output "cluster_security_group_id" {
  description = "Security group EKS created and attached to control plane ENIs and managed nodes."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_ids" {
  value = [for gateway in aws_nat_gateway.this : gateway.id]
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}

output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "ebs_csi_role_arn" {
  value = aws_iam_role.ebs_csi.arn
}

output "load_balancer_controller_role_arn" {
  description = "Exists before the Helm install. The chart is intentionally not part of this apply."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "resolved_addon_versions" {
  description = "Exact add-on versions this plan will request. Pod Identity Agent and EBS CSI come from the default compatible EKS API version."
  value = {
    vpc-cni                = local.pinned_addons["vpc-cni"]
    kube-proxy             = local.pinned_addons["kube-proxy"]
    coredns                = local.pinned_addons["coredns"]
    eks-pod-identity-agent = data.aws_eks_addon_version.pod_identity.version
    aws-ebs-csi-driver     = data.aws_eks_addon_version.ebs_csi.version
  }
}

output "update_kubeconfig_command" {
  description = "Writes a lab-local kubeconfig. It does not modify ~/.kube/config."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name} --kubeconfig ${path.module}/kubeconfig-${aws_eks_cluster.this.name} --alias ${aws_eks_cluster.this.name}"
}
