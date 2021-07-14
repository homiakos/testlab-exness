output "asg_names" {
  value = concat(
    module.single_az_asg.asgs_names,
    module.multi_az_asg.asgs_names,
    module.canary_multi_az_asg.asgs_names,
  )
}

output "asg_ids" {
  value = concat(
    module.single_az_asg.asgs_ids,
    module.multi_az_asg.asgs_ids,
    module.canary_multi_az_asg.asgs_ids,

  )
}

output "security_group_id" {
  value = aws_security_group.workers.id
}

output "iam_role_arn" {
  value = aws_iam_role.workers.arn
}

output "iam_role_name" {
  value = aws_iam_role.workers.name
}

output "tag" {
  value = "kubernetes.io/cluster/${var.cluster_name}"
}

output "instance_profile" {
  value = aws_iam_instance_profile.workers.arn
}

output "partial_userdata" {
  value = local.userdata
}
