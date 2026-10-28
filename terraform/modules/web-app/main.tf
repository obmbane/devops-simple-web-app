locals {
  # Identify the app's pods. Used in the Deployment and Service selectors, which can't change after creation.
  selector_labels = {
    "app.kubernetes.io/name" = var.name
  }

  labels = merge(local.selector_labels, {
    "app.kubernetes.io/managed-by" = "terraform"
  })
}

resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.selector_labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name  = var.name
          image = var.image

          port {
            name           = "http"
            container_port = var.container_port
          }

          readiness_probe {
            http_get {
              path = var.health_check_path
              port = "http"
            }
          }

          liveness_probe {
            http_get {
              path = var.health_check_path
              port = "http"
            }
          }

          resources {
            limits   = var.resources.limits
            requests = var.resources.requests
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    type     = "ClusterIP"
    selector = local.selector_labels

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}
