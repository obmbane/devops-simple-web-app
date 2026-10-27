variable "environment" {
  type        = string
  description = "Environment the namespace belongs to. Set as the environment label."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
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

variable "team" {
  type        = string
  description = "Team that owns the namespace. Set as the team label."

  validation {
    condition     = length(var.team) <= 63 && can(regex("^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$", var.team))
    error_message = "team must be a valid Kubernetes label value: at most 63 characters, starting and ending with a letter or digit, with only letters, digits, '-', '_' and '.' in between."
  }
}
