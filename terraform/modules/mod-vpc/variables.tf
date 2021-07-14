variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "central_private_vpc_peering_routes" {
  type = map

  default = {}
}

variable "s3_endpoint" {
  default = ""
}

variable "private_networks" {
  type = map

  default = {}
}

variable "public_networks" {
  type = map

  default = {}
}


variable "project" {
  default = "exness"
}

variable "environment" {
  default = ""
}
