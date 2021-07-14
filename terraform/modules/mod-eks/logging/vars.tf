variable "aws_region" {
}

variable "domain_name" {
}

variable "vpc_id" {
}

variable "cw_enabled" {
  default = 1
}

variable "tags" {
  type    = map(string)
  default = {}
}

