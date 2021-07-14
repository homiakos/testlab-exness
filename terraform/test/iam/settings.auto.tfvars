project         = "exness"
region          = "eu-central-1"
vpc_environment = "test"

standard_roles = {
  "AdministratorAccess" = "arn:aws:iam::aws:policy/AdministratorAccess"
  "PowerUserAccess"     = "arn:aws:iam::aws:policy/PowerUserAccess"
  "ReadOnlyAccess"      = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
