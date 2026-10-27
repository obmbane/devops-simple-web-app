output "name" {
  type        = string
  description = "Name of the namespace. Reference this, not the name variable, so dependent resources wait for the namespace to exist."
  value       = kubernetes_namespace_v1.this.metadata[0].name
}
