variable "name" {
  description = "Azure resource group name for k8s cluster"
}

variable "location" {
  description = "Azure location where the resource group should be created"
  default     = "eastus"
}

variable "tags" {
  description = "Tags used for resource group"
  default     = {}
  type        = "map"
}