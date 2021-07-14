resource "aws_cloudwatch_log_group" "cw" {
  count = var.cw_enabled ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, map("Domain", var.domain_name))
}
