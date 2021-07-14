output "standard_roles" {
  value = [for role in aws_iam_role.standard : role.arn]
}

output "idp_arn" {
  value = aws_iam_saml_provider.gsuite.arn
}

output "role_attributes_for_gsuite" {
  value = [for role in flatten([[for role in aws_iam_role.standard : role.arn]]) : "${role},${aws_iam_saml_provider.gsuite.arn}"]
}