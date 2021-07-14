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

variable "standard_roles" {
  description = "Roles with standard policies"
}
