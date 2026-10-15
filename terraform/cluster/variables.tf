variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
  default     = "simple-web-app"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name))
    error_message = "cluster_name must be lowercase letters, numbers and dashes, starting and ending with a letter or number."
  }
}

variable "node_image" {
  description = "Kind node image (sets the Kubernetes version)"
  type        = string
  default     = "kindest/node:v1.36.1"
}

variable "worker_count" {
  description = "Number of worker nodes. Changing this recreates the cluster."
  type        = number
  default     = 2

  validation {
    condition     = var.worker_count >= 1 && var.worker_count == floor(var.worker_count)
    error_message = "worker_count must be a whole number of at least 1, or the pods have nowhere to run."
  }
}

variable "kubeconfig_path" {
  description = "Where to write the cluster's kubeconfig. null uses ~/.kube/config"
  type        = string
  default     = null
}

variable "node_port" {
  description = "NodePort the app's Service will use. The app reads this from this config's outputs."
  type        = number
  default     = 30080

  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "node_port must be between 30000 and 32767 (the Kubernetes NodePort range)."
  }
}

variable "host_port" {
  description = "Port on your machine mapped to the NodePort"
  type        = number
  default     = 8080

  validation {
    condition     = var.host_port >= 1 && var.host_port <= 65535
    error_message = "host_port must be between 1 and 65535."
  }
}
