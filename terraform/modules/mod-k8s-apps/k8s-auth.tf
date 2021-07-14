locals {
  mapRoles_list = templatefile(
    "${path.module}/aws-auth.tmpl",
    {
      worker_role_arn     = var.worker_role_arn,
      cluster_admin_roles = var.cluster_admin_roles,
      cluster_reader_role = var.cluster_reader_role,
      user_roles          = aws_iam_role.user_roles,
      user_groups         = local.all_roles,
    }
  )
}

resource kubernetes_config_map "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = local.mapRoles_list
  }
}
