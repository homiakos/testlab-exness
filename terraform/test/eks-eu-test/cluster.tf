module "kubernetes" {
  source = "../../modules/mod-eks"

  cluster_name        = local.cluster_name
  eks_cluster_version = local.eks_cluster_version

  private_subnets     = [for subnet in aws_subnet.eks_private : subnet.id]
  public_subnets      = [for subnet in aws_subnet.eks_public : subnet.id]
  asg_private_subnets = [for subnet in aws_subnet.eks_asg_private : subnet.id]
  vpc_id              = local.vpc_id
  admin_sg            = [data.terraform_remote_state.vpc.outputs.vpn_sg]
  workers_ami_id      = local.workers_ami_id
  canary_ami_id       = local.canary_workers_ami_id

  workers_ssh_key = local.instance_key

  admin_role_name = "exness-EKS-Admin"

  offering        = local.offering
  project         = var.project
  vpc_environment = var.vpc_environment

  workers_multi_az_asg        = local.workers_multi_az_asg
  workers_single_az_asg       = local.workers_single_az_asg
  canary_workers_multi_az_asg = local.canary_workers_multi_az_asg

  dockerhub_proxy = "https://registry-proxy.aws-exness.ru"
}
