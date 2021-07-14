output app_roles {
  value = { for role in aws_iam_role.app_role : role.name => role.arn }
}

output ecr {
  value = [for ecr in aws_ecr_repository.ecr : ecr.repository_url]
}

output user_roles {
  value = [for role in aws_iam_role.user_roles : role.arn]
}

output namespace {
  value = [for ns in local.ns : ns.name]
}
