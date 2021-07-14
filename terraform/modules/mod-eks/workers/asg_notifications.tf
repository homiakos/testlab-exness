resource "aws_sns_topic" "workers_asg_updates" {
  count = var.sns_asg_updates_topic_name == "" ? 0 : 1
  name  = var.sns_asg_updates_topic_name
}

resource "aws_autoscaling_notification" "workers_asg_updates" {
  count = var.sns_asg_updates_topic_name == "" ? 0 : 1
  group_names = concat(
    module.single_az_asg.asgs_names,
    module.multi_az_asg.asgs_names,
    module.canary_multi_az_asg.asgs_names
  )

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = aws_sns_topic.workers_asg_updates[0].arn

  depends_on = [aws_sns_topic.workers_asg_updates]
}
