locals {
  app_roles = flatten([
    for ns in var.namespaces : [
      for role in lookup(ns, "create_app_iam_roles", null) == null ? [] : ns.create_app_iam_roles : [
        for env in ns.envs : {
          description = "Application IAM ROLE for Applications in ${ns.name}-${env} namespace",
          product     = ns.product,
          owner       = ns.owner,
          role_path   = "/k8s/${ns.name}-${env}/",
          role_name   = "${role}-${env}",
          ns_name     = "${ns.name}-${env}",
          labels      = lookup(ns, "labels", {}),
          annotations = lookup(ns, "annotations", {}),
        }
      ]
    ]
  ])
}

resource "aws_iam_role" "app_role" {
  for_each           = { for role in local.app_roles : role.role_name => role }
  path               = each.value.role_path
  name               = each.key
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(var.worker_role_arn)}
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_provider_url}:sub": "system:serviceaccount:${each.value.ns_name}:${each.key}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_provider_url}:sub": "system:serviceaccount:external-secrets-prod:external-secrets-prod"
        }
      }
    }
  ]
}
EOF

  tags = {
    Description  = each.value.description
    Product      = each.value.product
    Owner        = each.value.owner
    K8sNamespace = element(split("/", each.value.role_path), 2)
  }
}

resource "kubernetes_service_account" "app_sa" {
  for_each = { for role in local.app_roles : role.role_name => role }
  metadata {
    name      = each.key
    namespace = each.value.ns_name
    annotations = merge(
      {
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
        "eks.amazonaws.com/role-arn"  = aws_iam_role.app_role[each.key].arn
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }

  depends_on = [aws_iam_role.app_role]
}

