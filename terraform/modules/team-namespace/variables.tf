variable "environment" {
  type        = string
  description = "Environment the namespace belongs to. Set as the environment label."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "limit_range" {
  type = object({
    default_cpu_limit      = optional(string, "250m")
    default_cpu_request    = optional(string, "50m")
    default_memory_limit   = optional(string, "160Mi")
    default_memory_request = optional(string, "32Mi")
    max_cpu                = optional(string, "500m")
    max_memory             = optional(string, "256Mi")
  })
  description = "Per-container defaults and maximums, in Kubernetes quantities. Defaults apply to containers that don't set their own requests or limits."
  default     = {}
}


variable "name" {
  type        = string
  description = "Name of the namespace. Must be a valid RFC 1123 DNS label."

  validation {
    condition     = length(var.name) <= 63 && can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "name must be at most 63 characters, contain only lowercase letters, digits and '-', start with a letter and end with a letter or digit."
  }

  validation {
    condition     = !startswith(var.name, "kube-")
    error_message = "name must not start with \"kube-\", which is reserved for Kubernetes system namespaces."
  }
}

variable "resource_quota" {
  type = object({
    limits_cpu      = optional(string, "900m")
    limits_memory   = optional(string, "512Mi")
    node_ports      = optional(number, 0)
    pods            = optional(number, 3)
    requests_cpu    = optional(string, "300m")
    requests_memory = optional(string, "256Mi")
  })
  description = "Totals for all pods in the namespace, in Kubernetes quantities. Leave room for the extra pods a rolling update creates."
  default     = {}

  validation {
    condition = alltrue([
      for n in [var.resource_quota.node_ports, var.resource_quota.pods] : n >= 0 && n == floor(n)
    ])
    error_message = "resource_quota.node_ports and resource_quota.pods must be whole numbers of 0 or more."
  }
}


variable "team" {
  type        = string
  description = "Team that owns the namespace. Set as the team label."

  validation {
    condition     = length(var.team) <= 63 && can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", var.team))
    error_message = "team must be a valid Kubernetes label value: at most 63 characters, starting and ending with a letter or digit, with only letters, digits, '-', '_' and '.' in between."
  }
}
