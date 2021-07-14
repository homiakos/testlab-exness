resource "kubernetes_namespace" "ns" {
  for_each = { for ns in local.ns : ns.name => ns }
  metadata {
    name = each.key
    annotations = merge(
      {
        "iam.amazonaws.com/allowed-roles" = jsonencode(flatten([
          "k8s/${each.key}/*",
          [for role in each.value.app_iam_roles : role]
        ]))
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }
}

resource "kubernetes_limit_range" "resources" {
  for_each = { for ns in local.ns : ns.name => ns }
  metadata {
    name      = "limit-range"
    namespace = each.key
    annotations = merge(
      {
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = each.value.default_limit_cpu
        memory = each.value.default_limit_mem
      }
      default_request = {
        cpu    = each.value.default_request_cpu
        memory = each.value.default_request_mem
      }
    }
    limit {
      type = "Pod"
      max = {
        cpu    = each.value.max_limit_cpu
        memory = each.value.max_limit_mem
      }
      max_limit_request_ratio = {
        cpu    = each.value.max_cpu_ratio
        memory = each.value.max_mem_ratio
      }
    }
  }
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_limit_range" "disk" {
  for_each = { for ns in local.ns : ns.name => ns }
  metadata {
    name      = "limit-range-disk"
    namespace = each.key
    annotations = merge(
      {
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }
  spec {
    limit {
      type = "Container"
      default = {
        ephemeral-storage = each.value.default_limit_ephemeral_storage
      }
      default_request = {
        ephemeral-storage = each.value.default_request_ephemeral_storage
      }
    }
  }
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_resource_quota" "quota" {
  for_each = { for ns in local.ns : ns.name => ns }
  metadata {
    name      = "quota"
    namespace = each.key
    annotations = merge(
      {
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }
  spec {
    hard = {
      "count/configmaps"             = each.value.configmaps
      "count/cronjobs.batch"         = each.value.cronjobs
      "count/deployments.apps"       = each.value.deployments == "pods" ? each.value.pods : each.value.deployments
      "count/deployments.extensions" = each.value.deployments == "pods" ? each.value.pods : each.value.deployments
      "count/ingresses.extensions"   = each.value.ingresses
      "count/jobs.batch"             = each.value.jobs
      "count/secrets"                = each.value.secrets
      "count/services"               = each.value.services == "pods" ? each.value.pods : each.value.services
      "count/statefulsets.apps"      = each.value.statefulsets == "pods" ? each.value.pods : each.value.statefulsets
      "limits.cpu"                   = "${ceil(2.5 * tonumber(each.value.pods))}"
      "limits.ephemeral-storage"     = "${200 * each.value.pods}Gi"
      "limits.memory"                = "${4 * each.value.pods}Gi"
      "persistentvolumeclaims"       = each.value.volumes
      "requests.storage"             = each.value.volumes_size
      "pods"                         = each.value.pods
      "requests.cpu"                 = "${ceil(each.value.pods / 4)}"
      "requests.ephemeral-storage"   = "${200 * each.value.pods}Gi"
      "requests.memory"              = "${4 * each.value.pods}Gi"
    }
  }
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_service_account" "namespace_admin" {
  for_each = { for ns in local.ns : ns.name => ns }

  metadata {
    name      = "namespace-admin"
    namespace = each.key
  }
}

resource "kubernetes_role_binding" "users_rb" {
  for_each = { for ns in local.ns : ns.name => ns }

  metadata {
    name      = "users"
    namespace = each.key
    annotations = merge(
      {
        "k8s.aws-gopoints.ru/owner"   = each.value.owner
        "k8s.aws-gopoints.ru/project" = each.value.product
      },
      each.value.annotations
    )
    labels = merge(
      {
        "managed-by" = "terraform"
      },
      each.value.labels
    )
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "lmg-namespace-admin"
  }

  dynamic "subject" {
    for_each = flatten([each.value.group_name])
    content {
      kind      = "Group"
      name      = each.value.group_name
      namespace = ""
    }
  }

  subject {
    kind      = "Group"
    name      = "EKS-${title(each.value.original_name)}"
    namespace = ""
  }

  subject {
    kind      = "Group"
    name      = "EKS-${title(each.value.name)}"
    namespace = ""
  }

  subject {
    kind      = "ServiceAccount"
    name      = "namespace-admin"
    namespace = each.key
  }
}

locals {
  ns = flatten([
    for ns in var.namespaces : [
      for env in ns.envs : {
        name                              = "${ns.name}-${env}",
        original_name                     = ns.name,
        product                           = ns.product,
        owner                             = ns.owner,
        pods                              = ns.pods,
        volumes                           = lookup(ns, "volumes", 0),
        volumes_size                      = lookup(ns, "volumes_size", "0"),
        ecrs                              = lookup(ns, "ecrs", []),
        default_limit_mem                 = lookup(ns, "default_limit_mem", var.default_limit_mem),
        default_limit_cpu                 = lookup(ns, "default_limit_cpu", var.default_limit_cpu),
        default_request_mem               = lookup(ns, "default_request_mem", var.default_request_mem),
        default_request_cpu               = lookup(ns, "default_request_cpu", var.default_request_cpu),
        secrets                           = lookup(ns, "secrets", var.secrets),
        ingresses                         = lookup(ns, "ingresses", var.ingresses),
        cronjobs                          = lookup(ns, "cronjobs", var.cronjobs),
        jobs                              = lookup(ns, "jobs", var.jobs),
        configmaps                        = lookup(ns, "configmaps", var.configmaps),
        services                          = lookup(ns, "services", var.services),
        deployments                       = lookup(ns, "deployments", var.deployments),
        statefulsets                      = lookup(ns, "statefulsets", var.statefulsets),
        app_iam_roles                     = lookup(ns, "app_iam_roles", []),
        labels                            = lookup(ns, "labels", {}),
        annotations                       = lookup(ns, "annotations", {}),
        max_limit_cpu                     = lookup(ns, "max_limit_cpu", var.max_limit_cpu),
        max_limit_mem                     = lookup(ns, "max_limit_mem", var.max_limit_mem),
        max_cpu_ratio                     = lookup(ns, "max_cpu_ratio", var.max_cpu_ratio),
        max_mem_ratio                     = lookup(ns, "max_mem_ratio", var.max_mem_ratio),
        default_limit_ephemeral_storage   = lookup(ns, "default_limit_ephemeral_storage", var.default_limit_ephemeral_storage),
        default_request_ephemeral_storage = lookup(ns, "default_request_ephemeral_storage", var.default_request_ephemeral_storage),
        group_name                        = lookup(ns, "group_name", []),
      }
    ]
  ])
}
