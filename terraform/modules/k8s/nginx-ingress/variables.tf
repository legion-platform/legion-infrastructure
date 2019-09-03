variable "lb_ip_address" {
  description = "Cloud Load Balancer IP address used for k8s ingress"
}

variable "replicas" {
  default = "2"
}
