variable "registry_name" {
  type        = string
  description = "The name of the local registry"
  default     = "local-registry"
}

variable "registry_port" {
  type        = string
  description = "The port of the local registry"
  default     = "5001"
}
