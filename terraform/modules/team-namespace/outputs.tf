output "name" {
  type        = string
  description = "Name of the namespace. Reference this, not the name variable, so dependent resources wait for the namespace and its quota and limit range to exist."
  value       = kubernetes_namespace_v1.this.metadata[0].name

  # LimitRange and ResourceQuota only apply to pods admitted after they exist,
  # so make anything deployed into the namespace wait for them.
  depends_on = [
    kubernetes_limit_range_v1.this,
    kubernetes_resource_quota_v1.this,
  ]
}

