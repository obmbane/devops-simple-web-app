resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
      "team"                         = var.team
    }
  }
}

resource "kubernetes_resource_quota_v1" "this" {
  metadata {
    name      = "team-quota"
    namespace = kubernetes_namespace_v1.this.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    hard = {
      "limits.cpu"         = var.resource_quota.limits_cpu
      "limits.memory"      = var.resource_quota.limits_memory
      "pods"               = var.resource_quota.pods
      "requests.cpu"       = var.resource_quota.requests_cpu
      "requests.memory"    = var.resource_quota.requests_memory
      "services.nodeports" = var.resource_quota.node_ports
    }
  }
}

resource "kubernetes_limit_range_v1" "this" {
  metadata {
    name      = "container-limits"
    namespace = kubernetes_namespace_v1.this.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = var.limit_range.default_cpu_limit
        memory = var.limit_range.default_memory_limit
      }

      default_request = {
        cpu    = var.limit_range.default_cpu_request
        memory = var.limit_range.default_memory_request
      }

      max = {
        cpu    = var.limit_range.max_cpu
        memory = var.limit_range.max_memory
      }
    }
  }
}