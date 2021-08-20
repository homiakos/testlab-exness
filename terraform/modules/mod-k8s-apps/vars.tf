variable namespaces {
  description = "Namespaces"
  //  please refer to README for full options list
}

variable default_limit_mem {
  description = "Default value for pod memory limit"
  default     = "1Gi"
}

variable default_limit_cpu {
  description = "Default value for pod cpu limit"
  default     = "625m"
}

variable default_request_mem {
  description = "Default value for pod memory request "
  default     = "500Mi"
}

variable default_request_cpu {
  description = "Default value for pod cpu request "
  default     = "125m"
}

variable secrets {
  description = "Default value for number of secrets"
  default     = "300"
}

variable ingresses {
  description = "Default value for number of ingresses"
  default     = "300"
}

variable cronjobs {
  description = "Default value for number of cronjobs"
  default     = "300"
}

variable jobs {
  description = "Default value for number of jobs"
  default     = "300"
}

variable configmaps {
  description = "Default value for number of configmaps"
  default     = "300"
}

variable services {
  description = "Default value for number of services"
  default     = "pods"
}

variable deployments {
  description = "Default value for number of deployments"
  default     = "pods"
}

variable statefulsets {
  description = "Default value for number of statefulsets"
  default     = "pods"
}

variable max_limit_cpu {
  description = "max_limit_cpu"
  default     = "10"
}

variable max_limit_mem {
  description = "max_limit_memory"
  default     = "100Gi"
}

variable max_cpu_ratio {
  description = "max_cpu_ratio"
  default     = "30"
}

variable max_mem_ratio {
  description = "max_memory_ratio"
  default     = "30"
}

variable default_limit_ephemeral_storage {
  description = "default_limit_ephemeral_storage"
  default     = "100Gi"
}

variable default_request_ephemeral_storage {
  description = "default_request_ephemeral_storage"
  default     = "10Mi"
}

variable worker_role_arn {
  description = "Worker Node role ARN"
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

variable saml_provider_arn {
  description = "SAML provider ARN"
  type        = string
}

variable ecr_fullaccess_roles {
  description = "IAM roles with full access to ECRs"
  type        = list(string)
  default     = []
}

variable ecr_pullaccess_roles {
  description = "IAM roles with pull access to ECRs"
  type        = list(string)
  default     = []
}

variable eks_albs {
  description = "AWS ALBs used for cluster"
  default     = {}
}

variable oidc_provider_arn {
  description = "OIDC provider ARN to be used for SA to IAM assumption"
  default     = null
}

variable oidc_provider_url {
  description = "OIDC provider URL to be used for SA to IAM assumption"
  default     = null
}

variable scan_on_push {
  description = "Scan on push"
  default     = true
  type        = bool
}