resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.namespace
  }
}
