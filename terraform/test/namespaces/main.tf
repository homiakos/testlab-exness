# export shell environments with credenials
provider "aws" {
  region  = var.region
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
#  load_config_file       = false
}

# execute `terraform init` to set AWS s3 credentials
terraform {
  backend "s3" {
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket  = "exness-tfstate"
    key     = "${var.project}/terraform/${var.vpc_environment}/iam/terraform.tfstate"
    region  = "eu-central-1"
  }
}

data "terraform_remote_state" "eks" {
  for_each = toset(var.cluster_list)
  backend  = "s3"

  config = {
    bucket  = "exness-tfstate"
    key     = "${var.project}/terraform/${var.vpc_environment}/${each.key}/terraform.tfstate"
    region  = "eu-central-1"
  }
}


locals {
  cluster_worker_roles = [for eks in data.terraform_remote_state.eks : eks.outputs.worker_iam_role_arn]
}


data "aws_caller_identity" "current" {
}

module "namespace" {
  source = "../../modules/mod-k8s-apps"
  providers = {
    aws.dns = aws
  }

  namespaces          = var.namespaces
#  worker_role_arn     = var.worker_role_arn
  worker_role_arn     = local.cluster_worker_roles
  cluster_reader_role = var.cluster_reader_role
  cluster_admin_roles = var.cluster_admin_roles
  saml_provider_arn   = data.terraform_remote_state.iam.outputs.idp_arn
  ecr_fullaccess_roles = flatten([
    var.cluster_admin_roles
  ])
  ecr_pullaccess_roles = flatten([
    var.cluster_admin_roles,
    local.cluster_worker_roles
  ])
  oidc_provider_arn = data.terraform_remote_state.eks["${var.cluster_name}"].outputs.oidc["arn"]
  oidc_provider_url = data.terraform_remote_state.eks["${var.cluster_name}"].outputs.oidc["url"]
}
