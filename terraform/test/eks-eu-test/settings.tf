locals {
  cluster_name        = "eks-eu-test"
  eks_cluster_version = "1.18"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  offering     = "exness EU test EKS cluster"
  instance_key = "${var.project}-${var.vpc_environment}"

  enable_es_logging = false
  enable_cw_logging = false


  workers_ami_id        = "ami-0a3d7ac8c4302b317"
  canary_workers_ami_id = "ami-0a3d7ac8c4302b317"

  workers_security_group   = module.kubernetes.worker_security_group
  workers_instance_profile = module.kubernetes.workers_instance_profile
  partial_userdata         = module.kubernetes.workers_partial_userdata
  admin_iam_roles          = ["arn:aws:iam::002524799696:role/RAM-test-AdministratorAccess"]
  private_route_table_id   = data.terraform_remote_state.vpc.outputs.private_rts
  public_route_table_id    = data.terraform_remote_state.vpc.outputs.public_rt

  workers_multi_az_asg = [
    {
      asg_name = "mz2xlarge"
      types = [
        "m4.2xlarge",
        "m5.2xlarge",
        "c5.2xlarge",
        "r4.2xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "stateless"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "mz4xlarge"
      types = [
        "m4.4xlarge",
        "m5.4xlarge",
        "c5.4xlarge",
        "r4.4xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 400
      storage_type = "gp2"
      storage_iops = "1200"
      group_label  = "stateless"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    }
  ]

  workers_single_az_asg = [
    {
      asg_name = "sz2xlarge"
      types = [
        "m4.2xlarge",
        "m5.2xlarge",
        "c5.2xlarge",
        "r4.2xlarge",
      ]
      on_demand    = false
      min          = 1
      max          = 6
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "sz"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "ondemandsz2xlarge"
      types = [
        "m5.2xlarge",
        "c5.2xlarge",
        "r4.2xlarge",
      ]
      on_demand    = true
      min          = 0
      max          = 4
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "sz"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "sz12xlarge"
      types = [
        "m5.12xlarge",
        "c5.12xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 2000
      storage_type = "gp2"
      storage_iops = "6000"
      group_label  = "sz"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "coresz12xlarge"
      types = [
        "m5.12xlarge",
        "c5.12xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "core"
      taint        = true
      taint_label  = "node.aws-exness.ru/core-group=true:NoSchedule"
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "coresz4xlarge"
      types = [
        "m5.4xlarge",
        "m4.4xlarge",
        "r5.4xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "core"
      taint        = true
      taint_label  = "node.aws-exness.ru/core-group=true:NoSchedule"
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    }
  ]
  canary_workers_multi_az_asg = [
    {
      asg_name = "canary2xlarge"
      types = [
        "m4.2xlarge",
        "m5.2xlarge",
        "c5.2xlarge",
        "r4.2xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "canary"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    },
    {
      asg_name = "canary4xlarge"
      types = [
        "m4.4xlarge",
        "m5.4xlarge",
        "c5.4xlarge",
      ]
      on_demand    = false
      min          = 0
      max          = 0
      storage_size = 200
      storage_type = "gp2"
      storage_iops = "600"
      group_label  = "canary"
      taint        = false
      taint_label  = ""
      subnet_ids   = [for subnet in aws_subnet.eks_asg_sz_private : subnet.id]
    }
  ]

}

variable "private_networks" {
  description = "Private Networks to be used for EKS cluster"

  default = {
    eu-central-1a = "10.8.40.0/23"
    eu-central-1b = "10.8.42.0/23"
    eu-central-1c = "10.8.44.0/23"
  }
}

variable "public_networks" {
  description = "Public Networks to be used for EKS cluster"

  default = {
    eu-central-1a = "10.8.6.0/23"
    eu-central-1b = "10.8.8.0/23"
    eu-central-1c = "10.8.10.0/23"
  }
}

variable "asg_private_networks" {
  description = "Private Networks to be used for EKS cluster"

  default = {
    eu-central-1a = "10.8.46.0/23"
    eu-central-1b = "10.8.48.0/23"
    eu-central-1c = "10.8.50.0/23"
  }
}

variable "asg_sz_private_networks" {
  description = "Private Networks to be used for EKS cluster"

  default = {
    eu-central-1a = "10.8.72.0/21"
    eu-central-1b = "10.8.80.0/21"
    eu-central-1c = "10.8.88.0/21"
  }
}

