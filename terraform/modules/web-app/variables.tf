variable "container_port" {
  type        = number
  description = "Port the container listens on. The Service forwards to it and the probes check it."
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "HTTP path the readiness and liveness probes request. Must return a 2xx or 3xx status when the app is healthy."
  default     = "/healthz"
}

variable "image" {
  type        = string
  description = "Container image, with a tag (not latest) or a digest, e.g. docker.io/olly007/simple-web-app:v1."

  validation {
    condition     = can(regex("@sha256:[a-f0-9]{64}$", var.image)) || (can(regex(":[^/:]+$", var.image)) && !endswith(var.image, ":latest"))
    error_message = "image must include a tag other than latest, or a digest (@sha256:...)."
  }
}

variable "name" {
  type        = string
  description = "Name of the app. Used for the Deployment, the Service, and the app.kubernetes.io/name label."

  validation {
    condition     = length(var.name) <= 63 && can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be at most 63 characters, contain only lowercase letters, digits and '-', start with a letter and end with a letter or digit."
  }
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy into. Pass the namespace module's name output, so the app waits for the namespace to exist."
}

variable "replicas" {
  type        = number
  description = "Number of pods to run."
  default     = 1

  validation {
    condition     = var.replicas >= 1 && var.replicas == floor(var.replicas)
    error_message = "replicas must be a whole number of 1 or more."
  }
}

variable "resources" {
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  description = "CPU and memory requests and limits for the container, in Kubernetes quantities, e.g. cpu = \"50m\", memory = \"32Mi\"."
}