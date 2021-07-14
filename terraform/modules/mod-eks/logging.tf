module "logging" {
  source      = "./logging"
  cw_enabled  = var.enable_cw_logging
  domain_name = var.cluster_name
  vpc_id      = var.vpc_id

  aws_region = var.region

  tags = {
    "ManagedBy"   = "DevOps"
    "Project"     = var.project
    "Environment" = var.vpc_environment
  }
}
