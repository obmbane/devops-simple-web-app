variable "cluster_state_path" {
  description = "Path to the state file of ../cluster, used to read its outputs"
  type        = string
  default     = "../cluster/terraform.tfstate"
}

variable "namespace" {
  description = "Name of the team's namespace"
  type        = string
  default     = "team-catalog"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace)) && length(var.namespace) <= 63
    error_message = "namespace must be a valid Kubernetes name: lowercase letters, numbers and dashes, at most 63 characters."
  }
}

variable "team" {
  description = "Team that owns the namespace"
  type        = string
  default     = "catalog"
}

variable "environment" {
  description = "Environment the namespace belongs to"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

