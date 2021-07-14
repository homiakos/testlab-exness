# Variables

variable "project" {
  description = "Project name"
  default     = "exness"
}

variable "region" {
  description = "exness AWS region for test deployment"
  default     = "eu-central-1"
}

variable "vpc_environment" {
  description = "VPC environment"
  default     = "test"
}

