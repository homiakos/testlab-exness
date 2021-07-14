locals {
  roles_super_group = flatten([
    for ns in var.namespaces :
    lookup(ns, "group_name", null) != null ? [ns.group_name] : []
  ])

  roles_namespaces = flatten([
    for ns in var.namespaces : [
      for env in flatten(["", ns.envs]) :
      "EKS-${title("${ns.name}${env != "" ? "-${env}" : ""}")}"
    ]
  ])

  all_roles = distinct(flatten([local.roles_super_group, local.roles_namespaces]))
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      identifiers = [var.saml_provider_arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["https://signin.aws.amazon.com/saml"]
      variable = "SAML:aud"
    }
  }
}

resource "aws_iam_role" "user_roles" {
  for_each             = { for role in local.all_roles : role => role }
  name                 = each.value
  max_session_duration = 28800
  assume_role_policy   = data.aws_iam_policy_document.main.json

  tags = {
    ManagedBy   = "DevOps"
    Description = "Role for EKS users"
    Purpose     = "EKS"
  }
}
