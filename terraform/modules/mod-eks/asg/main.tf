locals {
  kubelet_extra_args = <<ARGS
--runtime-cgroups=/systemd/system.slice \
--kubelet-cgroups=/systemd/system.slice \
--enforce-node-allocatable=pods \
--eviction-hard=imagefs.available<15%,memory.available<5%,nodefs.available<10%,nodefs.inodesFree<5% \
--serialize-image-pulls=false \
--v=3 \
--pod-max-pids=8192 \
ARGS

  asg_sz = var.single_az == true ? flatten([
    for asg in var.worker_instance_asgs : [
      for subnet_id in asg.subnet_ids : {
        subnet_id    = [subnet_id]
        asg_name     = "${asg.asg_name}-${element(split("-", subnet_id), 1)}"
        types        = asg.types
        on_demand    = asg.on_demand
        min          = asg.min
        max          = asg.max
        storage_size = asg.storage_size
        storage_type = asg.storage_type
        storage_iops = asg.storage_type == "gp2" ? 0 : asg.storage_iops
        userdata     = "${var.userdata} --kubelet-extra-args \"${local.kubelet_extra_args} --node-labels=node.aws-exness.ru/group=${asg.group_label},node.aws-exness.ru/type=${asg.on_demand ? "ondemand" : "spot"} ${asg.on_demand || asg.taint ? "--register-with-taints=" : ""}${asg.on_demand ? "node.aws-exness.ru/type=true:PreferNoSchedule" : ""}${asg.on_demand && asg.taint ? "," : ""}${asg.taint && asg.taint_label == "" ? "node.aws-exness.ru/${asg.group_label}=true:NoSchedule" : ""}${asg.taint && asg.taint_label != "" ? "${asg.taint_label}" : ""}\" \"${var.cluster_name}\""
        group_label  = asg.group_label
        taint        = asg.taint
        taint_label  = asg.taint_label
      }
    ]
  ]) : []
  asg_mz = var.single_az == false ? flatten([
    for asg in var.worker_instance_asgs : {
      subnet_id    = asg.subnet_ids
      asg_name     = asg.asg_name
      types        = asg.types
      on_demand    = asg.on_demand
      min          = asg.min
      max          = asg.max
      storage_size = asg.storage_size
      storage_type = asg.storage_type
      storage_iops = asg.storage_type == "gp2" ? 0 : asg.storage_iops
      userdata     = "${var.userdata} --kubelet-extra-args \"${local.kubelet_extra_args} --node-labels=node.aws-exness.ru/group=${asg.group_label},node.aws-exness.ru/type=${asg.on_demand ? "ondemand" : "spot"} ${asg.on_demand || asg.taint ? "--register-with-taints=" : ""}${asg.on_demand ? "node.aws-exness.ru/type=true:PreferNoSchedule" : ""}${asg.on_demand && asg.taint ? "," : ""}${asg.taint && asg.taint_label == "" ? "node.aws-exness.ru/${asg.group_label}=true:NoSchedule" : ""}${asg.taint && asg.taint_label != "" ? "${asg.taint_label}" : ""}\" \"${var.cluster_name}\""
      group_label  = asg.group_label
      taint        = asg.taint
      taint_label  = asg.taint_label
    }
  ]) : []

  asg = flatten([local.asg_sz, local.asg_mz])
  //  asg = { for asg in flatten([local.asg_sz, local.asg_mz]) : asg.asg_name => asg }

  userdata = {
    for asg in var.worker_instance_asgs :
    "${asg.asg_name}" => "${var.userdata} --kubelet-extra-args \"${local.kubelet_extra_args} --node-labels=node.aws-exness.ru/group=${asg.group_label},node.aws-exness.ru/type=${asg.on_demand ? "ondemand" : "spot"} ${asg.on_demand || asg.taint ? "--register-with-taints=" : ""}${asg.on_demand ? "node.aws-exness.ru/type=true:PreferNoSchedule" : ""}${asg.on_demand && asg.taint ? "," : ""}${asg.taint && asg.taint_label == "" ? "node.aws-exness.ru/${asg.group_label}=true:NoSchedule" : ""}${asg.taint && asg.taint_label != "" ? "${asg.taint_label}" : ""}\" \"${var.cluster_name}\""
  }
}

resource "aws_autoscaling_group" "workers" {
  for_each = { for asg in local.asg : asg.asg_name => asg }

  name                = "${var.cluster_name}-workers-asg-${each.key}${length(each.value.subnet_id) == 3 ? "-multi-az" : ""}"
  max_size            = each.value.max
  min_size            = each.value.min
  vpc_zone_identifier = each.value.subnet_id

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = each.value.on_demand ? 100 : 0
      # spot_instance_pools                      = 2
      spot_allocation_strategy = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.workers[element(split("-", each.key), 0)].id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = each.value.types
        content {
          instance_type = override.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name                                                                  = "${var.cluster_name}-workers-asg-${each.key}${length(each.value.subnet_id) == 3 ? "-multi-az" : ""}"
      "kubernetes.io/cluster/${var.cluster_name}"                           = "owned"
      "exness-offering"                                                   = var.offering
      "exness-offering-component"                                         = each.value.on_demand ? "on-demand" : "spot"
      "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage" = "${each.value.storage_size}Gi"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_launch_template" "workers" {
  for_each = { for asg in var.worker_instance_asgs : asg.asg_name => asg }

  name_prefix = "lt-${replace(var.cluster_name, "/[^A-Za-z0-9]/", "")}${replace(each.key, "/[^A-Za-z0-9]/", "")}"
  # set to first isntance tpye on types list; will be overriden anyway
  instance_type          = each.value.types[0]
  image_id               = var.ami_id
  key_name               = var.ssh_key
  vpc_security_group_ids = var.security_group_ids
  user_data              = base64encode(local.userdata[element(split("-", each.key), 0)])
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = each.value.storage_type
      volume_size           = each.value.storage_size
      iops                  = each.value.storage_type == "gp2" ? 0 : each.value.storage_iops
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      "exness-offering"                         = var.offering,
      "exness-offering-component"               = each.value.on_demand ? "ondemand" : "spot",
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    })
  }

  tags = merge(var.common_tags, {
    "exness-offering"                         = var.offering,
    "exness-offering-component"               = each.value.on_demand ? "ondemand" : "spot",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

