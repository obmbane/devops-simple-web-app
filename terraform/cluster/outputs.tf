# ---- Read by ../app to connect to the cluster ----

output "endpoint" {
  description = "Kubernetes API server address"
  value       = kind_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "CA certificate used to trust the API server"
  value       = kind_cluster.this.cluster_ca_certificate
  sensitive   = true
}

output "client_certificate" {
  description = "Client certificate for the cluster admin user"
  value       = kind_cluster.this.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Private key for the cluster admin user"
  value       = kind_cluster.this.client_key
  sensitive   = true
}

output "node_port" {
  description = "NodePort mapped to your machine. The app's Service must use this port."
  value       = var.node_port
}

# ---- For you ----

output "kube_context" {
  description = "kubectl context for the cluster"
  value       = "kind-${kind_cluster.this.name}"
}

output "url" {
  description = "Where the app will be reachable once ../app is applied"
  value       = "http://localhost:${var.host_port}"
}
