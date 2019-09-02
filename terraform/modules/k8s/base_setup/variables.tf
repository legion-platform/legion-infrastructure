##################
# Common
##################
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "tls_namespaces" {
  default     = ["default", "kube-system"]
  description = "Default namespaces with TLS secret"
}

variable "tls_crt" {
  description = "TLS secret (certificate)"
}

variable "tls_key" {
  description = "TLS secret (key)"
}
