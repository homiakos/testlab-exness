locals {
  registry = flatten([
    for ns in var.namespaces : [
      for ecr in lookup(ns, "ecrs", []) : {
        description = "${ns.name} ${ecr} registry",
        product     = ns.product,
        owner       = ns.owner,
        registry    = "${ns.name}/${ecr}",
        fullaccess_roles = flatten([
          var.ecr_fullaccess_roles,
          [for env in ns.envs : aws_iam_role.user_roles["EKS-${title("${ns.name}-${env}")}"].arn],
          aws_iam_role.user_roles["EKS-${title(ns.name)}"].arn,
        ]),
      }
    ]
  ])
}

resource "aws_ecr_repository" "ecr" {
  for_each = { for ecr in local.registry : ecr.registry => ecr }
  name     = each.key
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Decription = each.value.description
    Owner      = each.value.owner
    Product    = each.value.product
  }
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  for_each   = { for ecr in local.registry : ecr.registry => ecr }
  depends_on = [aws_ecr_repository.ecr]

  repository = each.key
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "ecr" {
  for_each   = { for ecr in local.registry : ecr.registry => ecr }
  repository = each.key
  depends_on = [aws_ecr_repository.ecr]

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(each.value.fullaccess_roles)}
      },
      "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:GetAuthorizationToken"
      ]
    },
    {
      "Sid": "2",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(var.ecr_pullaccess_roles)}
      },
      "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetAuthorizationToken"
      ]
    }
  ]
}
EOF
}
