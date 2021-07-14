# Variables

variable project {
  description = "Project name"
  default     = "exness"
}

variable region {
  description = "AWS region for instance deployment"
  default     = "eu-central-1"
}

variable vpc_environment {
  description = "VPC environment"
  default     = "test"
}

variable namespaces {
  description = "Namespaces"
}

variable cluster_name {
  description = "EKS cluster name"
  type        = string
}

variable worker_role_arn {
  description = "EKS cluster worker role ARN"
  type        = list(string)
}

variable cluster_admin_roles {
  description = "EKS cluster admin roles"
  type        = list(string)
}

variable cluster_reader_role {
  description = "IAM role for ReadOnly access"
  type        = list(string)
}

variable cluster_list {
  description = "List of clusters running in same AWS account to be allowed pull images"
  default     = []
}
