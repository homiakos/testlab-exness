resource "aws_iam_role" "workers" {
  name = "${var.cluster_name}-workers"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

//,
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "Federated": "${var.oidc_provider_arn}"
//      },
//      "Action": "sts:AssumeRoleWithWebIdentity",
//      "Condition": {
//        "StringEquals": {
//          "${var.oidc_provider_url}:sub": "system:serviceaccount:kube-system:cluster-admin"
//        }
//      }
//    }


resource "aws_iam_policy" "autoscaler_policy_worker" {
  name        = "${var.cluster_name}_cluster_autoscaler_policy_worker"
  path        = "/"
  description = "AWS Cluster Autoscaler IAM policy"

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Action" = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeLaunchTemplate*"
        ],
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" = concat(
          module.canary_multi_az_asg.asgs_arns,
          module.multi_az_asg.asgs_arns,
          module.single_az_asg.asgs_arns
        )
      }
    ]
  })
}

resource "aws_iam_policy" "kube2iam_policy" {
  name = "${var.cluster_name}-kube2iam-policy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_policy" "cloudwatch_logging_policy" {
  count       = var.enable_cloudwatch_logging_iam ? 1 : 0
  name        = "${var.cluster_name}_cluster_cloudwatch_logging_policy"
  path        = "/"
  description = "AWS Worker CloudWatch logging IAM policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging_policy_attachment" {
  count      = var.enable_cloudwatch_logging_iam ? 1 : 0
  policy_arn = aws_iam_policy.cloudwatch_logging_policy[0].arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "kube2iam_policy_attachment" {
  policy_arn = aws_iam_policy.kube2iam_policy.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "autoscaler_policy_attachment_worker" {
  count      = var.enable_autoscaler_iam ? 1 : 0
  policy_arn = aws_iam_policy.autoscaler_policy_worker.arn
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_instance_profile" "workers" {
  name = "${var.cluster_name}-workers"
  role = aws_iam_role.workers.name
}
