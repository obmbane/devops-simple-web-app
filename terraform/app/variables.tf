variable "cluster_state_path" {
  description = "Path to the state file of ../cluster, used to read its outputs"
  type        = string
  default     = "../cluster/terraform.tfstate"
}

variable "namespace" {
  description = "Namespace for the application"
  type        = string
  default     = "simple-web-app"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace)) && length(var.namespace) <= 63
    error_message = "namespace must be a valid Kubernetes name: lowercase letters, numbers and dashes, at most 63 characters."
  }
}

variable "app_name" {
  description = "Name used for the Deployment, Service, ConfigMap and labels"
  type        = string
  default     = "simple-web-app"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.app_name)) && length(var.app_name) <= 57
    error_message = "app_name must be lowercase letters, numbers and dashes, at most 57 characters (\"-nginx\" is added for the ConfigMap)."
  }
}

variable "image_repository" {
  description = "Container image repository"
  type        = string
  default     = "olly007/simple-web-app"
}

variable "image_tag" {
  description = "Container image tag. Change this to release a new version."
  type        = string
  default     = "v1"

  validation {
    condition     = var.image_tag != "" && var.image_tag != "latest"
    error_message = "image_tag must be a pinned version such as \"v2\", not empty or \"latest\"."
  }
}

variable "replicas" {
  description = "Number of pods"
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1 && var.replicas == floor(var.replicas)
    error_message = "replicas must be a whole number of at least 1."
  }
}

variable "resources" {
  description = "CPU and memory requests and limits for each pod"
  type = object({
    requests = object({ cpu = string, memory = string })
    limits   = object({ cpu = string, memory = string })
  })
  default = {
    requests = { cpu = "50m", memory = "32Mi" }
    limits   = { cpu = "200m", memory = "128Mi" }
  }
}

variable "probes" {
  description = "Health check path and timings for the readiness and liveness probes. Any field left out keeps its default."
  type = object({
    path = optional(string, "/healthz")
    readiness = optional(object({
      initial_delay_seconds = optional(number, 2)
      period_seconds        = optional(number, 5)
      failure_threshold     = optional(number, 3)
    }), {})
    liveness = optional(object({
      initial_delay_seconds = optional(number, 10)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
    }), {})
  })
  default = {}

  validation {
    condition     = startswith(var.probes.path, "/")
    error_message = "probes.path must start with \"/\"."
  }
}
