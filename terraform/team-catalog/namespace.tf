locals {
  # Labels shared by everything this configuration creates
  common_labels = {
    "team"                         = var.team
    "environment"                  = var.environment
    "app.kubernetes.io/managed-by" = "terraform"
  }
}

resource "kubernetes_namespace_v1" "team_catalog" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

