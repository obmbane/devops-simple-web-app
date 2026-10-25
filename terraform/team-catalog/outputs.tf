output "namespace" {
  description = "Name of the team's namespace"
  value       = kubernetes_namespace_v1.team_catalog.metadata[0].name
}

output "labels" {
  description = "Labels applied to the namespace"
  value       = kubernetes_namespace_v1.team_catalog.metadata[0].labels
}

