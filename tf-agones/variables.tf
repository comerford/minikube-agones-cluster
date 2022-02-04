variable "agones_version" {
  default = "1.19.0"
}

variable "kubernetes_version" {
  default = "1.21"
}
variable "feature_gates" {
  default = "PlayerTracking=true"
}
variable "log_level" {
  default = "info"
}
