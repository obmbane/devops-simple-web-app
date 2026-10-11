output "image" {
  description = "Image the Deployment is running"
  value       = "${var.image_repository}:${var.image_tag}"
}

output "service_dns" {
  description = "DNS name other pods use to reach the app"
  value       = "${kubernetes_service_v1.app.metadata[0].name}.${kubernetes_namespace_v1.app.metadata[0].name}.svc.cluster.local"
}

output "url" {
  description = "Open this in your browser"
  value       = local.cluster.url
}