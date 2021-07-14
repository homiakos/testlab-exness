output kubeconfig {
  value = module.eks-cluster.kubeconfig
}

output worker_iam_role_name {
  value = module.workers.iam_role_name
}

output worker_iam_role_arn {
  value = module.workers.iam_role_arn
}

output worker_asg_names {
  value = module.workers.asg_names
}

output worker_security_group {
  value = module.workers.security_group_id
}

output cluster_tag {
  value = module.workers.tag
}

output region {
  value = var.region
}

output enable_chaos {
  value = var.enable_chaos
}

output enable_es_logging {
  value = var.enable_es_logging
}

output enable_cw_logging {
  value = var.enable_cw_logging
}

output cw_log_group_name {
  value = module.logging.cw_log_group_name
}

output "workers_instance_profile" {
  value = module.workers.instance_profile
}

output "workers_partial_userdata" {
  value = module.workers.partial_userdata
}

output "cluster_api" {
  value = module.eks-cluster.endpoint
}

output "eks_ca" {
  value = module.eks-cluster.eks_ca
}

output "worker_asg_ids" {
  value = module.workers.asg_ids
}

output "oidc" {
  value = module.eks-cluster.oidc
}
