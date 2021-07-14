output "cluster_name" {
  value = local.cluster_name
}

output "admin_iam_roles" {
  value = local.admin_iam_roles
}

output "kubeconfig" {
  value = module.kubernetes.kubeconfig
}

output "worker_iam_role_arn" {
  value = module.kubernetes.worker_iam_role_arn
}

output "worker_security_group" {
  value = module.kubernetes.worker_security_group
}

output "asg_tags" {
  value = module.kubernetes.worker_asg_names
}

output "aws_default_region" {
  value = module.kubernetes.region
}

output "cluster_tag" {
  value = module.kubernetes.cluster_tag
}

output "cluster_api" {
  value = module.kubernetes.cluster_api
}

output "oidc" {
  value = module.kubernetes.oidc
}

output "eks_cluster_version" {
  value = local.eks_cluster_version
}

output "private_networks" {
  value = var.private_networks
}

output "public_networks" {
  value = var.private_networks
}

output "asg_private_networks" {
  value = var.asg_private_networks
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.eks_private : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.eks_public : subnet.id]
}

output "asg_private_subnet_ids" {
  value = [for subnet in aws_subnet.eks_asg_private : subnet.id]
}
