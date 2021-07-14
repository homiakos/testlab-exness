variable worker_instance_asgs {
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
}

variable single_az {
  type = bool
}

variable cluster_name {
  type = string
}

variable offering {
  type = string
}

variable ami_id {
  type = string
}

variable ssh_key {
  type = string
}

variable security_group_ids {
  type = list(string)
}

variable userdata {
  type    = string
  default = ""
}

variable iam_instance_profile_name {
  type = string
}

variable common_tags {
  type    = map
  default = {}
}
