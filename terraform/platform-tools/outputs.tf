output "service_account_username" {
  type        = string
  description = "Username the API server sees for the health-checker ServiceAccount. Use with kubectl auth can-i --as to check its permissions."
  value       = "system:serviceaccount:${kubernetes_service_account_v1.health_checker.metadata[0].namespace}:${kubernetes_service_account_v1.health_checker.metadata[0].name}"
}

output "token_command" {
  type        = string
  description = "Command that prints a short-lived token for the health-checker ServiceAccount."
  value       = "kubectl create token ${kubernetes_service_account_v1.health_checker.metadata[0].name} --namespace ${kubernetes_service_account_v1.health_checker.metadata[0].namespace} --context kind-simple-web-app"
}
