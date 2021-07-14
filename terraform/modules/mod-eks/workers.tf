module "workers" {
  source                        = "./workers"
  private_subnet_ids            = var.private_subnets
  asg_private_subnet_ids        = var.asg_private_subnets
  ami_id                        = var.workers_ami_id
  canary_ami_id                 = var.canary_ami_id
  cluster_name                  = var.cluster_name
  ssh_key                       = var.workers_ssh_key
  vpc_id                        = var.vpc_id
  cluster_security_group        = module.eks-cluster.security_group
  admin_role_name               = var.admin_role_name
  cluster_endpoint              = module.eks-cluster.endpoint
  cluster_ca                    = module.eks-cluster.eks_ca
  enable_autoscaler_iam         = var.workers_autoscaler_iam
  enable_cloudwatch_logging_iam = var.enable_cw_logging
  sns_asg_updates_topic_name    = var.workers_asg_updates_sns_topic

  offering = var.offering

  workers_multi_az_asg        = var.workers_multi_az_asg
  workers_single_az_asg       = var.workers_single_az_asg
  canary_workers_multi_az_asg = var.canary_workers_multi_az_asg
  oidc_provider_arn           = module.eks-cluster.oidc["arn"]
  oidc_provider_url           = module.eks-cluster.oidc["url"]

  admin_networks = var.admin_networks
  admin_sg       = var.admin_sg

  dockerhub_proxy = var.dockerhub_proxy
}
