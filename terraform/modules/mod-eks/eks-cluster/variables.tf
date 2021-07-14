variable "eks_cluster_name" {}

variable "eks_private_subnets" {
  type = list
}

variable "eks_vpc_id" {}

variable "eks_cluster_version" {}

variable "eks_logs_enabled" {
  type    = list
  default = ["scheduler", "controllerManager", "api"]
}

variable "admin_sg" {
  type    = list
  default = []
}

variable "admin_networks" {
  type    = list
  default = []
}
