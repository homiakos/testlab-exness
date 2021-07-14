output cw_log_group_name {
  value = var.cw_enabled ? join(",", aws_cloudwatch_log_group.cw.*.name) : "not available"
}
