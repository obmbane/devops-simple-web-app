# NodePort Service: reachable inside the cluster by DNS name,
# and from your machine through the Kind port mapping
resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace_v1.app.metadata[0].name
    labels    = local.labels
  }

  spec {
    type     = "NodePort"
    selector = local.labels

    port {
      name        = "http"
      port        = 80 # standard HTTP port inside the cluster
      target_port = "http"
      # Must match the cluster's port mapping, so it comes from ../cluster
      node_port = local.cluster.node_port
    }
  }
}
