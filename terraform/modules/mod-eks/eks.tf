module "eks-cluster" {
  source              = "./eks-cluster"
  eks_cluster_name    = var.cluster_name
  eks_private_subnets = var.private_subnets
  eks_vpc_id          = var.vpc_id
  eks_cluster_version = var.eks_cluster_version
  eks_logs_enabled    = var.eks_logs_enabled
  admin_networks      = var.admin_networks
  admin_sg            = var.admin_sg
}
