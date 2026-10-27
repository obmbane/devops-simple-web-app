output "client_certificate" {
  type        = string
  description = "Client certificate of the cluster's admin user. Used with client_key to authenticate to the API server."
  value       = kind_cluster.this.client_certificate
}

output "client_key" {
  type        = string
  description = "Private key of the cluster's admin user. Hidden in CLI output, but stored in plain text in state."
  value       = kind_cluster.this.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  type        = string
  description = "CA certificate used to verify the API server's identity."
  value       = kind_cluster.this.cluster_ca_certificate
}

output "endpoint" {
  type        = string
  description = "Address of the Kubernetes API server."
  value       = kind_cluster.this.endpoint
}

output "kube_context" {
  type        = string
  description = "Name of the kubectl context for the cluster (normally kind-<name>)."
  value       = kind_cluster.this.context_name
}

output "name" {
  type        = string
  description = "Name of the Kind cluster."
  value       = kind_cluster.this.name
}