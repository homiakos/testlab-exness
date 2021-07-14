variable ami_id {}

variable canary_ami_id {}

variable private_subnet_ids {
  type = list
}

variable asg_private_subnet_ids {
  type = list
}

variable cluster_name {}
variable ssh_key {}

variable enable_autoscaler_iam {
  default = true
}

variable enable_cloudwatch_logging_iam {
  default = true
}

variable vpc_id {}
variable cluster_security_group {}
variable admin_role_name {}
variable cluster_ca {}
variable cluster_endpoint {}

variable sns_asg_updates_topic_name {
  default = ""
}

variable offering {
  description = "Offering tag"
}

variable "additional_sg_rules" {
  type    = list
  default = []
}

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

variable "oidc_provider_arn" {}
variable "oidc_provider_url" {}

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
