#
# Required variables
#
variable cluster_name {
  description = "String used as prefix for uniquely naming resources"
}

variable eks_cluster_version {}

variable offering {
  description = "Human readable cluster name, used for billing accounting"
}

variable vpc_id {}

variable admin_role_name {
  description = "AWS IAM Role name for admin access"
}

variable private_subnets {
  type = list
}

variable public_subnets {
  type = list
}

variable asg_private_subnets {
  type = list
}

variable workers_ssh_key {}

variable workers_ami_id {}

variable canary_ami_id {}

#
# Other options
#
variable region {
  default = "eu-central-1"
}

variable workers_autoscaler_iam {
  default = true
}

variable enable_chaos {
  default = false
}

variable enable_cw_logging {
  default = false
}

variable enable_es_logging {
  default = false
}

variable workers_asg_updates_sns_topic {
  default = ""
}

variable "eks_logs_enabled" {
  type    = list
  default = ["scheduler", "controllerManager", "api"]
}

variable "project" {}

variable "vpc_environment" {}

variable "workers_single_az_asg" {
  type = list(
    object({
      asg_name     = string,
      types        = list(string),
      on_demand    = bool,
      min          = number,
      max          = number,
      storage_size = number,
      storage_type = string,
      storage_iops = number,
      group_label  = string,
      taint        = bool,
      taint_label  = string,
      subnet_ids   = list(string)
    })
  )
  default = []
}

variable "workers_multi_az_asg" {
  type = list(
    object({
      asg_name     = string,
      types        = list(string),
      on_demand    = bool,
      min          = number,
      max          = number,
      storage_size = number,
      storage_type = string,
      storage_iops = number,
      group_label  = string,
      taint        = bool,
      taint_label  = string,
      subnet_ids   = list(string)
    })
  )
  default = []
}

variable "canary_workers_multi_az_asg" {
  type = list(
    object({
      asg_name     = string,
      types        = list(string),
      on_demand    = bool,
      min          = number,
      max          = number,
      storage_size = number,
      storage_type = string,
      storage_iops = number,
      group_label  = string,
      taint        = bool,
      taint_label  = string,
      subnet_ids   = list(string)
    })
  )
  default = []
}

variable "admin_sg" {
  type    = list
  default = []
}

variable "admin_networks" {
  type    = list
  default = []
}

variable "dockerhub_proxy" {
  type = string
}
