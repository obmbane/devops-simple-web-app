output "service_dns_name" {
  type        = string
  description = "DNS name that pods in any namespace use to reach the app, e.g. http://<this>/."
  value       = "${kubernetes_service_v1.this.metadata[0].name}.${kubernetes_service_v1.this.metadata[0].namespace}"
}

output "node_port" {
  type        = number
  description = "Port opened on every node, or null when service_type is ClusterIP."
  value       = var.service_type == "NodePort" ? kubernetes_service_v1.this.spec[0].port[0].node_port : null
}
