output asgs_arns {
  value = [for asg_name, value in aws_autoscaling_group.workers : value.arn]
}

output asgs_names {
  value = [for asg_name, value in aws_autoscaling_group.workers : value.name]
}

output asgs_ids {
  value = [for asg_name, value in aws_autoscaling_group.workers : value.id]
}
