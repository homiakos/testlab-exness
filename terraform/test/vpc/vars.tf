# Variables

variable "project" {
  description = "Project name"
  default     = "exness"
}

variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "vpc_environment" {
  description = "VPC environment"
  default     = "test"
}

variable "private_networks" {
  description = "private networks"
}

variable "public_networks" {
  description = "public networks"
}
variable "vpc_cidr" {
  description = "VPC CIDR"
}

variable "vpc_name" {
  description = "VPC name"
}

variable "s3_endpoint" {
  description = "S3 endpoint"
  default     = ""
}