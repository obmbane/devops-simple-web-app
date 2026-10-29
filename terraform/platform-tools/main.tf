locals {
  # Namespaces the health checker may read. Add each new team namespace here.
  watched_namespaces = toset(["team-catalog", "team-olly"])
}

module "namespace" {
  source = "../modules/team-namespace"

  environment = "prod"
  name        = "platform-tools"
  team        = "platform"
}

resource "kubernetes_service_account_v1" "health_checker" {
  metadata {
    name      = "health-checker"
    namespace = module.namespace.name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # Used from outside the cluster with a token from kubectl create token,
  # so no pod should get its token mounted automatically.
  automount_service_account_token = false
}

resource "kubernetes_cluster_role_v1" "health_checker" {
  metadata {
    name = "health-checker"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }
}

# A RoleBinding (not a ClusterRoleBinding) limits the ClusterRole's rules to that one namespace.
resource "kubernetes_role_binding_v1" "health_checker" {
  for_each = local.watched_namespaces

  metadata {
    name      = "health-checker"
    namespace = each.value

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.health_checker.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.health_checker.metadata[0].name
    namespace = kubernetes_service_account_v1.health_checker.metadata[0].namespace
  }
}