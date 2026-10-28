output "service_dns_name" {
  type        = string
  description = "DNS name that pods in any namespace use to reach the app, e.g. http://<this>/."
  value       = "${kubernetes_service_v1.this.metadata[0].name}.${kubernetes_service_v1.this.metadata[0].namespace}"
}
