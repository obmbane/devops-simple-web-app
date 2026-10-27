variable "name" {
  type        = string
  description = "Name of the Kind cluster. The kubectl context will be kind-<name>."
  default     = "simple-web-app"
}

variable "node_image" {
  type        = string
  description = "Kind node image, which sets the Kubernetes version. Pin it by digest, as the Kind docs recommend."
  default     = "kindest/node:v1.37.0@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5"
}

variable "port_mappings" {
  type = list(object({
    container_port = number
    host_port      = number
    listen_address = optional(string, "127.0.0.1")
  }))
  description = "Ports on your machine forwarded to the control-plane node, e.g. to reach a NodePort Service. Bound to 127.0.0.1 unless listen_address is set."
  default     = []
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes. Changing it recreates the cluster, because Kind can't add nodes to a running cluster."
  default     = 2

  validation {
    condition     = var.worker_count >= 0 && var.worker_count == floor(var.worker_count)
    error_message = "worker_count must be a whole number of 0 or more."
  }
}