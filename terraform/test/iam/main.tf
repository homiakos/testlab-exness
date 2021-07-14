resource "aws_iam_role" "standard" {
  for_each             = var.standard_roles
  name                 = "RAM-test-${each.key}"
  max_session_duration = 28800
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRoleWithSAML",
      "Effect": "Allow",
      "Condition": {
          "StringEquals": {
              "SAML:aud": "https://signin.aws.amazon.com/saml"
          }
      },
      "Principal": {
          "Federated": "${aws_iam_saml_provider.gsuite.arn}"
      }
    }
  ]
}
EOF

  tags = {
    ManagedBy   = "DevOps"
    Description = "${each.key} Role"
  }

  depends_on = [aws_iam_saml_provider.gsuite]
}

resource "aws_iam_role_policy_attachment" "standard" {
  for_each   = var.standard_roles
  policy_arn = each.value
  role       = "RAM-test-${each.key}"

  depends_on = [aws_iam_role.standard]
}
