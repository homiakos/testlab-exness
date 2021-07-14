output "namespace" {
  value = module.namespace.namespace
}

output "user_roles" {
  value = module.namespace.user_roles
}

output "ecr" {
  value = module.namespace.ecr
}

output "app_roles" {
  value = module.namespace.app_roles
}

output "gsuite_role_attributes" {
  value = [for role in module.namespace.user_roles : "${role},${data.terraform_remote_state.iam.outputs.idp_arn}"]
}