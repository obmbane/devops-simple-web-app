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
